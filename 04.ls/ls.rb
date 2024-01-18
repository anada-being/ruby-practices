#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

MAX_ROW = 3

def file_import
  Dir.foreach('.').to_a.filter { |file| !file.start_with?('.') }
end

def all_file_import
  Dir.foreach('.').to_a
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

def file_export(tate_files)
  max_length = tate_files.map { |files| files.map(&:length).max }.max
  tate_files.each do |files|
    files.each do |file_name|
      print file_name
      (max_length - file_name.length + 2).times { print ' ' }
    end
    print "\n"
  end
end

opt = OptionParser.new
params = {}
opt.on('-a') { |v| params[:a] = v }
opt.on('-r') { |v| params[:r] = v }
opt.parse(ARGV)

array_files = params[:a] ? all_file_import : file_import
array_files = array_files.reverse if params[:r]
tate_files = file_convert(array_files)
file_export(tate_files)
