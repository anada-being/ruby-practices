#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

# 一度だけ実行し、@opt_paramsはこれ以降変更しない
def define_option_boolean
  opt_params = { l: false, w: false, c: false }
  opt = OptionParser.new

  opt.on('-l') { |v| opt_params[:l] = v }
  opt.on('-w') { |v| opt_params[:w] = v }
  opt.on('-c') { |v| opt_params[:c] = v }
  opt.parse!(ARGV)
  opt_params
end

def main
  inputs = ARGV.empty? ? readlines : ARGV
  count_result = {
    lines: count_lines(inputs),
    words: count_words(inputs),
    bytes: count_bytes(inputs)
  }
  count_result.map do |_key, val|
    val.each_with_index do |v, i|
      val[i] = 0 if v.nil?
    end
  end
  trimmed_data = trim_data(count_result)

  ARGV.empty? ? output_standard(**trimmed_data) : output_file(**trimmed_data)
end

def count_lines(inputs)
  inputs = if FileTest.readable?(inputs[0])
            inputs.map do |f|
              next if FileTest.directory?(f)

              File.read(f)
            end
          else
            [ inputs.join ]
          end
  inputs.map do |string|
    next if string.nil?

    string.count("\n", "/[^\n]\z/")
  end
end

def count_words(inputs)
  inputs = if FileTest.readable?(inputs[0])
              inputs.map do |f|
                next if FileTest.directory?(f)

                File.read(f)
              end
            else
              [ inputs.join(' ') ]
            end
  inputs.map do |string|
    next if string.nil?

    string.split.size
  end
end

def count_bytes(inputs)
  if FileTest.readable?(inputs[0])
    inputs.map do |f|
      next if FileTest.directory?(f)

      File.stat(f).size
    end
  else
    [ inputs.join.bytesize ]
  end
end

def trim_data(count_result)
  if @opt_params.value?(true)
    count_result.delete(:lines) unless @opt_params[:l]
    count_result.delete(:words) unless @opt_params[:w]
    count_result.delete(:bytes) unless @opt_params[:c]
  end
  count_result
end

def output_standard(**count_result)
  count_result.each_value do |val|
    val.each { |v| printf('%8s', "#{v} ") }
  end
  puts "\n"
end

def output_file(**count_result)
  directory_exist = false
  ARGV.each_with_index do |f, i|
    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      directory_exist = true
    end
    count_result.each_value do |val|
      directory_exist ? printf('%8s', "#{val[i]} ") : printf('%5s', "#{val[i]} ")
    end
    puts f
  end
  totals = calculate_total(count_result)
  totals.each do |v|
    next if v.zero?

    directory_exist ? printf('%8s', "#{v} ") : printf('%5s', "#{v} ")
  end
  puts 'total'
end

def calculate_total(count_result)
  count_result.map { |_key, val| val.sum }
end

@opt_params = define_option_boolean
main
