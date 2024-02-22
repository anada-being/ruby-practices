#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  options, paths = receive_command_argument
  if paths.empty?
    output(count_stdin, options)
  else
    output(count_file(paths), options)
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

def count_stdin
  inputs = $stdin.readlines.join
  count = {
    line: count_lines(inputs),
    word: count_words(inputs),
    byte: inputs.size
  }
  [count]
end

def count_file(paths)
  paths.map do |file_name|
    property = { line: 0, word: 0, byte: 0, name: '', directory: false }
    if FileTest.file?(file_name)
      file_data = File.read(file_name)
      property[:line] = count_lines(file_data)
      property[:word] = count_words(file_data)
      property[:byte] = file_data.size
    end
    property[:name] = file_name
    property[:directory] = FileTest.directory?(file_name)
    property
  end
end

def count_lines(text)
  text.lines.size
end

def count_words(text)
  text.split.size
end

def output(file_properties, options)
  only_files = file_properties.none? { |hash| hash[:directory] == true }
  only_files = file_properties[0].key?(:directory) if only_files
  padding_right = only_files ? 5 : 8
  file_properties.each do |property|
    puts "wc: #{property[:name]}: Is a directory" if property[:directory]
    output_by_options(property, options, padding_right)
    puts property[:name]
  end
  return if file_properties.size == 1

  totals = calculate_total(file_properties)
  output_by_options(totals, options, padding_right)
  puts 'total'
end

def output_by_options(hash, options, padding_right)
  options = options.transform_values(&:!) unless options.value?(true)
  print "#{hash[:line]} ".rjust(padding_right) if options[:l]
  print "#{hash[:word]} ".rjust(padding_right) if options[:w]
  print "#{hash[:byte]} ".rjust(padding_right) if options[:c]
end

def calculate_total(counts)
  totals = { line: 0, word: 0, byte: 0 }
  counts.each do |property|
    totals[:line] += property[:line]
    totals[:word] += property[:word]
    totals[:byte] += property[:byte]
  end
  totals
end

main
