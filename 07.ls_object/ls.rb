#!/usr/bin/env ruby

# frozen_string_literal: true

require './file_etc'
require 'optparse'

class LS
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
    files = Dir.foreach(path)
    filenames = dot_match ? files.to_a : files.filter { |file| !file.start_with?('.') }
    filenames_sorted = sort_filename(filenames)
    reverse ? filenames_sorted.reverse : filenames_sorted
  end

  def sort_filename(filenames)
    filenames.sort do |a, b|
      a = a.slice(1..-1) if a.start_with?('.') && !['.', '..'].include?(a)
      b = b.slice(1..-1) if b.start_with?('.') && !['.', '..'].include?(b)
      a.downcase <=> b.downcase
    end
  end

  def list_long(filenames)
    file_etc_objects = filenames.map { |filename| FileEtc.new(filename) }
    block_total = file_etc_objects.sum(&:blocks) / 2
    total = "total #{block_total}"
    body = format_body(file_etc_objects)
    [total, *body].join("\n")
  end

  def format_body(file_etc_objects)
    max_sizes = %i[nlink user group size].map do |key|
      file_etc_objects.map { |file_etc_obj| key_size(file_etc_obj, key.to_s) }.max
    end
    file_etc_objects.map { |file_etc_obj| format_row(file_etc_obj, *max_sizes) }
  end

  def key_size(file_etc_obj, key)
    keys = {
      'nlink' => file_etc_obj.nlink.to_s.size,
      'user' => file_etc_obj.user.size,
      'group' => file_etc_obj.group.size,
      'size' => file_etc_obj.file_size.to_s.size,
      'mtime' => file_etc_obj.mtime.size,
      'blocks' => file_etc_obj.blocks.size
    }
    keys[key]
  end

  def format_row(file_etc_obj, max_nlink, max_user, max_group, max_size)
    [
      file_etc_obj.type_and_mode,
      file_etc_obj.nlink.to_s.rjust(max_nlink),
      file_etc_obj.user.ljust(max_user),
      file_etc_obj.group.ljust(max_group),
      file_etc_obj.file_size.to_s.rjust(max_size),
      file_etc_obj.mtime,
      file_etc_obj.name
    ].join(' ')
  end

  def list_short(filenames)
    row_count = (filenames.count.to_f / MAX_ROW).ceil
    formatted_for_transpose = filenames.each_slice(row_count).to_a
    transposed_filenames = safe_transpose(formatted_for_transpose)
    max_filename_count = filenames.map(&:size).max
    format_table(transposed_filenames, max_filename_count)
  end

  def safe_transpose(nested_file_names)
    nested_file_names[0].zip(*nested_file_names[1..])
  end

  def format_table(filenames, max_filename_count)
    filenames.map do |row_files|
      row_files
        .map { |file_name| file_name.to_s.ljust(max_filename_count + 1) }
        .join
        .rstrip
    end.join("\n")
  end
end

LS.new.main
