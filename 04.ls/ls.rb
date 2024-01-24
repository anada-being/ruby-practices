#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'

MAX_ROW = 3
BLOCK = 1024
DIRECTORY = 16_384
REGULAR_FILE = 32_768
SYMBOLIC_LINK = 40_960

def file_import
  Dir.foreach('.').to_a.filter { |file| !file.start_with?('.') }.sort_by { |s| [s.downcase, s] }
end

def all_file_import
  Dir.foreach('.').to_a.sort_by { |s| [s.downcase, s] }
end

def convert_mode(num)
  f_type = if num > SYMBOLIC_LINK
             num -= SYMBOLIC_LINK
             +'l'
           elsif num > REGULAR_FILE
             num -= REGULAR_FILE
             +'-'
           elsif num > DIRECTORY
             num -= DIRECTORY
             +'d'
           end
  permission = num.to_s(8).gsub(/./, '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx')
  f_type.concat(permission)
end

def file_stat(array_files)
  file_mode = []
  array_files.each do |f|
    s = File.stat(f)
    c = convert_mode(s.mode)
    u_g_name = "#{Etc.getpwuid(s.uid).name} #{Etc.getgrgid(s.gid).name}"
    file_mode << [c, s.nlink.to_s, u_g_name, s.size.to_s, s.mtime.strftime('%b %e %R'), f].join(' ')
  end
  file_mode
end

def size_total(array_files)
  sum = array_files.map { |f| File.stat(f).blocks / 2 }.sum
  puts "total #{sum}"
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
opt.on('-l') { |v| params[:l] = v }
opt.parse(ARGV)

array_files = params[:a] ? all_file_import : file_import
array_files = array_files.reverse if params[:r]
tate_files = file_convert(array_files)
if params[:l]
  size_total(array_files)
  puts file_stat(array_files)
else
  file_export(tate_files)
end
