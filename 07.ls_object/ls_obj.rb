#!/usr/bin/env ruby

# frozen_string_literal: true

require './file_and_directory'
require 'optparse'

MAX_ROW = 3

def main
  opt = OptionParser.new

  params = { dot_match: false, long_format: false, reverse: false }
  opt.on('-a') { |v| params[:dot_match] = v }
  opt.on('-l') { |v| params[:long_format] = v }
  opt.on('-r') { |v| params[:reverse] = v }
  opt.parse!(ARGV)
  path = '.'

  puts run_ls(path, **params)
end

def run_ls(path, dot_match: false, long_format: false, reverse: false)
  filenames = collect_files(path, dot_match, reverse)
  long_format ? list_long(filenames) : list_short(filenames)
end

def collect_files(path, dot_match, reverse)
  filenames = dot_match ? Dir.foreach(path).to_a : Dir.foreach(path).filter { |file| !file.start_with?('.') }
  filenames = filename_sort(filenames)
  reverse ? filenames.reverse : filenames
end

def filename_sort(filenames)
  filenames.sort do |a, b|
    a = a.slice(1..-1) if a.start_with?('.') && !['.', '..'].include?(a)
    b = b.slice(1..-1) if b.start_with?('.') && !['.', '..'].include?(b)
    a.downcase <=> b.downcase
  end
end

def list_long(filenames)
  row_data = filenames.map { |filename| FileAndDirectory.new(filename) }
  block_total = row_data.sum(&:blocks) / 2
  total = "total #{block_total}"
  body = format_body(row_data)
  [total, *body].join("\n")
end

def format_body(row_data)
  max_sizes = %i[nlink user group size].map do |key|
    row_data.map { |data| data.key_size(key.to_s) }.max
  end
  row_data.map { |data| format_row(data, *max_sizes) }
end

def format_row(data, max_nlink, max_user, max_group, max_size)
  [
    data.type_and_mode,
    " #{data.nlink.rjust(max_nlink)}",
    " #{data.user.ljust(max_user)}",
    " #{data.group.ljust(max_group)}",
    " #{data.file_size.rjust(max_size)}",
    " #{data.mtime}",
    " #{data.name}"
  ].join
end

def list_short(filenames)
  row_count = (filenames.count.to_f / MAX_ROW).ceil
  transposed_filenames = safe_transpose(filenames.each_slice(row_count).to_a)
  max_filename_count = filenames.map(&:size).max
  format_table(transposed_filenames, max_filename_count)
end

def safe_transpose(nested_file_names)
  nested_file_names[0].zip(*nested_file_names[1..])
end

def format_table(filenames, max_filename_count)
  filenames.map do |row_files|
    row_files.map { |file_name| file_name.to_s.ljust(max_filename_count + 1) }.join.rstrip
  end.join("\n")
end

main
