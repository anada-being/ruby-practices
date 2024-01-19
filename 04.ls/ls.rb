#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'

MAX_ROW = 3
BLOCK = 1024

def file_import
  Dir.foreach('.').sort.to_a.filter { |file| !file.start_with?('.') }
end

def all_file_import
  Dir.foreach('.').sort.to_a
end

# パーミッションの文字に変換
def convert_mode(num)
  num.gsub(/./, '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx')
end

def file_stat(array_files)
  file_mode = []
  array_files.each_with_index do |f, i|
    s = File.stat(f)
    num = s.mode
    if num > 40_960 # シンボリックリンク
      num -= 40_960
      file_mode << (+'l' << convert_mode(num.to_s(8)) << ' ')
    elsif num > 32_768 # 通常ファイル
      num -= 32_768
      file_mode << (+'-' << convert_mode(num.to_s(8)) << ' ')
    elsif num > 16_384 # ディレクトリ
      num -= 16_384
      file_mode << (+'d' << convert_mode(num.to_s(8)) << ' ')
    end
    file_mode[i].concat(s.nlink.to_s, ' ', Etc.getpwuid(s.uid).name, ' ', Etc.getgrgid(s.gid).name, ' ', s.size.to_s, ' ', s.mtime.strftime('%b %e %R'), ' ', f)
  end
  file_mode
end

def size_total(array_files)
  sum = 0
  array_files.each do |f|
    s = File.stat(f).size
    next if s.zero?

    # 4096以下は４、それ以上は1024で割った商+1
    sum += s < BLOCK * 4 + 1 ? 4 : s / BLOCK + 1
  end
  print 'total '
  p sum
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
