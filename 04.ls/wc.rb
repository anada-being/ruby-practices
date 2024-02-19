#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  cmd_arg = receive_command_argument
  opt_params = cmd_arg[0]
  argv = cmd_arg[1]
  if argv.empty?
    std_data = make_std
    output(std_data, opt_params)
  else
    lwc_data = make_lwc(argv)
    output(lwc_data, opt_params)
  end
end

def receive_command_argument
  opt_params = { l: false, w: false, c: false }
  opt = OptionParser.new

  opt.on('-l') { |v| opt_params[:l] = v }
  opt.on('-w') { |v| opt_params[:w] = v }
  opt.on('-c') { |v| opt_params[:c] = v }
  argv = opt.parse(ARGV)
  [opt_params, argv]
end

def make_std
  inputs = $stdin.readlines
  formatted_inputs = inputs.join
  count = { line: 0, word: 0, byte: 0, new_line: ' ' }
  count[:line] = count_lines(formatted_inputs)
  count[:word] = count_words(formatted_inputs)
  count[:byte] = formatted_inputs.size
  [count]
end

def make_lwc(argv)
  argv.map do |file_name|
    lwc = { line: 0, word: 0, byte: 0, name: '', directory: false }
    if FileTest.file?(file_name)
      file_data = File.read(file_name)
      lwc[:line] = count_lines(file_data)
      lwc[:word] = count_words(file_data)
      lwc[:byte] = file_data.size
    end
    lwc[:name] = file_name
    lwc[:directory] = true if FileTest.directory?(file_name)
    lwc
  end
end

def count_lines(text)
  text.lines.size
end

def count_words(text)
  text.split.size
end

def output(lwc_data, opt_params)
  lwc_data.each do |lwc|
    puts "wc: #{lwc[:name]}: Is a directory" if lwc[:directory]
    output_detail(lwc, opt_params)
  end
  return if lwc_data.size == 1

  totals = calculate_total(lwc_data)
  totals.each_value { |v| print "#{v} ".rjust(8) }
  puts 'total'
end

def output_detail(lwc, opt_params)
  if opt_params.value?(true)
    print "#{lwc[:line]} ".rjust(8) unless opt_params[:l]
    print "#{lwc[:word]} ".rjust(8) unless opt_params[:w]
    print "#{lwc[:byte]} ".rjust(8) unless opt_params[:c]
  else
    lwc.each_value do |v|
      print "#{v} ".rjust(8) if v.is_a?(Integer)
    end
  end
  puts lwc[:name]
end

def calculate_total(lwc_data)
  totals = { line: 0, word: 0, byte: 0 }
  lwc_data.each do |lwc|
    totals[:line] += lwc[:line]
    totals[:word] += lwc[:word]
    totals[:byte] += lwc[:byte]
  end
  totals
end

main
