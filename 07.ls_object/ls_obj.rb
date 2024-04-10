#!/usr/bin/env ruby

# frozen_string_literal: true

require './directory_stat'
require './file_stat'
require 'optparse'

MAX_ROW = 3

def main
  opt = OptionParser.new

  params = { dot_match: false, long_format: false, reverse: false }
  opt.on('-a') { |v| params[:dot_match] = v }
  opt.on('-l') { |v| params[:long_format] = v }
  opt.on('-r') { |v| params[:reverse] = v }
  opt.parse!(ARGV)
  path = ARGV[0] || '.'

  puts run_ls(path, **params)
end

def run_ls(path, dot_match: false, long_format: false, reverse: false)
  filenames = collect_files(path, dot_match, reverse)
  long_format ? list_long(filenames) : list_short(filenames)
end

def collect_files(path, dot_match, reverse)
  filenames = dot_match ? Dir.foreach(path) : Dir.foreach(path).filter { |file| !file.start_with?('.') }
  filenames.to_a.sort_by { |s| [s.downcase, s] }
  reverse ? filenames.reverse : filenames
end

def list_long(filenames)
  row_data = filenames.map do |filename|
    if FileTest.directory?(filename)
      directory = DirectoryStat.new(filename)
      directory.build_data
    else
      file = FileStat.new(filename)
      file.build_data
    end
  end
  block_total = row_data.sum { |data| data[:blocks] } / 2
  total = "total #{block_total}"
  body = format_body(row_data)
  [total, *body].join("\n")
end

def format_body(row_data)
  max_sizes = %i[nlink user group size].map do |key|
    row_data.map { |data| data[key].size }.max
  end
  row_data.map { |data| format_row(data, *max_sizes) }
end

def format_row(data, max_nlink, max_user, max_group, max_size)
  [
    data[:type_and_mode],
    "  #{data[:nlink].rjust(max_nlink)}",
    " #{data[:user].ljust(max_user)}",
    "  #{data[:group].ljust(max_group)}",
    "  #{data[:size].rjust(max_size)}",
    " #{data[:mtime]}",
    " #{data[:basename]}"
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
