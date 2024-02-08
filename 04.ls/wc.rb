#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  inputs = ARGV.empty? ? readlines : ARGV
  count_result = {
    lines: count_lines(inputs),
    words: count_words(inputs),
    bytes: count_bytes(inputs)
  }
  count_result.map do |_key, val|
    next if val.instance_of?(Integer)

    val.each_with_index do |v, i|
      val[i] = 0 if v.nil?
    end
  end
  trimmed_data = trim_data(count_result)

  ARGV.empty? ? output_standard(trimmed_data) : output_file(*trimmed_data)
end

def count_lines(inputs)
  if FileTest.readable?(inputs[0])
    inputs.map do |f|
      next if FileTest.directory?(f)

      File.read(f).count("\n", "/[^\n]\z/")
    end
  else
    inputs.join.count("\n", "/[^\n]\z/")
  end
end

def count_words(inputs)
  if FileTest.readable?(inputs[0])
    inputs.map do |f|
      next if FileTest.directory?(f)

      File.read(f).split.size
    end
  else
    inputs.join(' ').split.size
  end
end

def count_bytes(inputs)
  if FileTest.readable?(inputs[0])
    inputs.map do |f|
      next if FileTest.directory?(f)

      File.stat(f).size
    end
  else
    inputs.join.bytesize
  end
end

def trim_data(count_result)
  opt_bool = define_option_boolean
  count_result.delete(:lines) if opt_bool[:l]
  count_result.delete(:words) if opt_bool[:w]
  count_result.delete(:bytes) if opt_bool[:c]
  count_result
end

def define_option_boolean
  opt = OptionParser.new
  params = { l: false, w: false, c: false }
  opt.on('-l') { |v| params[:l] = v }
  opt.on('-w') { |v| params[:w] = v }
  opt.on('-c') { |v| params[:c] = v }
  opt.parse!(ARGV)
  { l: params[:l], w: params[:w], c: params[:c] }
end

def output_standard(count_result)
  count_result.each_value do |val|
    printf('%8s', "#{val} ")
  end
  puts "\n"
end

def output_file(*count_result)
  directory_exist = false
  totals = { lines: 0, words: 0, bytes: 0 }
  ARGV.each_with_index do |f, i|
    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      directory_exist = true
    end
    count_result.each do |key, val|
      directory_exist ? printf('%8s', "#{val[i]} ") : printf('%5s', "#{val[i]} ")
      totals[key] += val[i]
    end
    puts f
  end
  totals.each_value do |v|
    next if v.zero?

    directory_exist ? printf('%8s', "#{v} ") : printf('%5s', "#{v} ")
  end
  puts 'total'
end

main
