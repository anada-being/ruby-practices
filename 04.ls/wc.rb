#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  argv = define_option_boolean[1]
  if argv.empty?
    inputs = $stdin.readlines
    formatted_inputs = inputs.join
    count = { line: 0, word: 0, byte: 0 }
    count[:line] = count_lines(formatted_inputs)
    count[:word] = count_words(formatted_inputs)
    count[:byte] = formatted_inputs.size
    formatted_lwc = format_lwc(**count)
    output_standard(formatted_lwc)
  else
    output_file(make_lwc)
  end
end

def define_option_boolean
  opt_params = { l: false, w: false, c: false }
  opt = OptionParser.new

  opt.on('-l') { |v| opt_params[:l] = v }
  opt.on('-w') { |v| opt_params[:w] = v }
  opt.on('-c') { |v| opt_params[:c] = v }
  argv = opt.parse(ARGV)
  [opt_params, argv]
end

def make_lwc
  argv = define_option_boolean[1]
  lwc_data = []
  argv.each do |file_name|
    lwc = { line: 0, word: 0, byte: 0, name: '' }
    if FileTest.file?(file_name)
      file_data = File.read(file_name)
      lwc[:line] = count_lines(file_data)
      lwc[:word] = count_words(file_data)
      lwc[:byte] = File.stat(file_name).size
    end
    lwc[:name] = file_name
    lwc_data << format_lwc(**lwc)
  end
  lwc_data
end

def count_lines(strings)
  strings.count("\n", "/[^\n]\z/")
end

def count_words(strings)
  strings.split.size
end

def format_lwc(**lwc)
  opt_params = define_option_boolean[0]
  if opt_params.value?(true)
    lwc.delete(:line) unless opt_params[:l]
    lwc.delete(:word) unless opt_params[:w]
    lwc.delete(:byte) unless opt_params[:c]
  end
  lwc
end

def output_standard(count_result)
  count_result.each_value do |val|
    printf('%8s', "#{val} ")
  end
  puts "\n"
end

def output_file(lwc_data)
  directory_exist = 5
  lwc_data.each do |lwc|
    if lwc.value?(0)
      puts "wc: #{lwc[:name]}: Is a directory"
      directory_exist = 8
    end
    lwc.each_value do |v|
      if v.is_a?(Integer)
        printf("%#{directory_exist}s", "#{v} ")
      else
        puts v
      end
    end
  end
  totals = calculate_total(lwc_data)
  totals.each_value { |v| printf("%#{directory_exist}s", "#{v} ") }
  puts 'total'
end

def calculate_total(lwc_data)
  totals = { line: 0, word: 0, byte: 0 }
  lwc_data.each do |lwc|
    totals[:line] += lwc[:line] unless lwc[:line].nil?
    totals[:word] += lwc[:word] unless lwc[:word].nil?
    totals[:byte] += lwc[:byte] unless lwc[:byte].nil?
  end
  format_lwc(**totals)
  totals
end

main
