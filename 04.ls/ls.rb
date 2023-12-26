#!/usr/bin/env ruby

# frozen_string_literal: true

MAX_ROW = 3

def file_import
  @max_length = 0
  @array_files = []
  Dir.foreach('.') do |item|
    next if item.start_with?(".")

    @array_files << item
    @max_length = item.length if @max_length < item.length
  end
end

def file_convert
  file_import
  array_row = @array_files.size / MAX_ROW
  remainder = @array_files.size % MAX_ROW
  array_row += 1 unless remainder.zero?
  array_nil = 0
  array_nil = MAX_ROW - remainder unless remainder.zero?
  yoko_files = []
  @array_files.each_slice(array_row) { |file| yoko_files << file }
  array_nil.times { yoko_files[MAX_ROW - 1] << 'dummy' }
  @tate_files = yoko_files.transpose
  array_nil.times { |i| @tate_files[array_row - 1 - i].pop }
end

def file_export
  file_convert
  @tate_files.each do |files|
    files.each do |file_name|
      blank_length = @max_length - file_name.length + 2
      print file_name
      blank_length.times { print ' ' }
    end
    print "\n"
  end
end

file_export
