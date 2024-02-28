#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  options, paths = parse_options
  paths.empty? ? calculate_stdin : calculate_file_text(paths)
  output(file_properties, options)
end

def parse_options
  options = { l: false, w: false, c: false }
  opt = OptionParser.new

  opt.on('-l') { |v| options[:l] = v }
  opt.on('-w') { |v| options[:w] = v }
  opt.on('-c') { |v| options[:c] = v }
  paths = opt.parse(ARGV)
  [options, paths]
end

def calculate_stdin
  input = $stdin.readlines.join
  property = {
    line: count_lines(input),
    word: count_words(input),
    byte: input.size,
    name: '',
    directory: false
  }
  [property]
end

def calculate_file_text(paths)
  paths.map do |path|
    property = { line: 0, word: 0, byte: 0 }
    if FileTest.file?(path)
      file_texts = File.read(path)
      property[:line] = count_lines(file_texts)
      property[:word] = count_words(file_texts)
      property[:byte] = file_texts.size
    end
    property[:name] = path
    property[:directory] = FileTest.directory?(path)
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
  is_only_files = file_properties.none? { |property| property[:directory] }
  is_only_files = file_properties[0].key?(:directory) if is_only_files
  width = is_only_files ? 5 : 8
  file_properties.each do |property|
    puts "wc: #{property[:name]}: Is a directory" if property[:directory]
    output_by_options(property, options, width)
  end
  return if file_properties.size == 1

  totals = calculate_total(file_properties)
  output_by_options(totals, options, width)
end

def output_by_options(property, options, width)
  no_options = !options.value?(true)
  print "#{property[:line]} ".rjust(width) if options[:l] || no_options
  print "#{property[:word]} ".rjust(width) if options[:w] || no_options
  print "#{property[:byte]} ".rjust(width) if options[:c] || no_options
  puts property[:name]
end

def calculate_total(file_properties)
  totals = { line: 0, word: 0, byte: 0, name: 'total', directory: false }
  file_properties.each do |property|
    totals[:line] += property[:line]
    totals[:word] += property[:word]
    totals[:byte] += property[:byte]
  end
  totals
end

main
