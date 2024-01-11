#!/usr/bin/env ruby

# frozen_string_literal: true

MAX_ROW = 3

def file_import
  array_files = Dir.foreach('.').to_a.filter { |file| !file.start_with?('.') }
  max_length = array_files.map(&:length).max
  [array_files, max_length]
end

def file_convert(array_files)
  array_row = array_files.size / MAX_ROW
  remainder = array_files.size % MAX_ROW
  array_row += 1 unless remainder.zero?
  dummy_number = remainder.zero? ? 0 : (MAX_ROW - remainder)
  yoko_files = array_files.each_slice(array_row).to_a
  dummy_number.times { yoko_files[MAX_ROW - 1] << 'dummy' }
  tate_files = yoko_files.transpose
  dummy_number.times { |i| tate_files[array_row - 1 - i].pop }
  tate_files
end

def file_export(tate_files, max_length)
  tate_files.each do |files|
    files.each do |file_name|
      print file_name
      (max_length - file_name.length + 2).times { print ' ' }
    end
    print "\n"
  end
end

array_files, max_length = file_import
tate_files = file_convert(array_files)
file_export(tate_files, max_length)
