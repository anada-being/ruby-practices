#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  options, paths = receive_command_argument
  paths.empty? ? output(count_stdin, options) : output(calculate_file_text(paths), options)
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

def calculate_file_text(paths)
  paths.map do |file_name|
    property = { line: 0, word: 0, byte: 0, name: '', directory: false }
    if FileTest.file?(file_name)
      file_texts = File.read(file_name)
      property[:line] = count_lines(file_texts)
      property[:word] = count_words(file_texts)
      property[:byte] = file_texts.size
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
  is_only_files = file_properties.none? { |property| property[:directory] == true }
  is_only_files = file_properties[0].key?(:directory) if is_only_files
  padding_left = is_only_files ? 5 : 8
  file_properties.each do |property|
    puts "wc: #{property[:name]}: Is a directory" if property[:directory]
    output_by_options(property, options, padding_left)
  end
  return if file_properties.size == 1

  totals = calculate_total(file_properties)
  output_by_options(totals, options, padding_left)
end

def output_by_options(property, options, padding_left)
  options = options.transform_values(&:!) unless options.value?(true)
  print "#{property[:line]} ".rjust(padding_left) if options[:l]
  print "#{property[:word]} ".rjust(padding_left) if options[:w]
  print "#{property[:byte]} ".rjust(padding_left) if options[:c]
  puts property[:name]
end

def calculate_total(counts)
  totals = { line: 0, word: 0, byte: 0, name: 'total' }
  counts.each do |property|
    totals[:line] += property[:line]
    totals[:word] += property[:word]
    totals[:byte] += property[:byte]
  end
  totals
end

main
