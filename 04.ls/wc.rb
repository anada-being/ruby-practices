#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def line_count(files)
  files.map do |f|
    next if FileTest.directory?(f)

    File.read(f).count("\n", "/[^\n]\z/")
  end
end

def word_count(files)
  files.map do |f|
    next if FileTest.directory?(f)

    File.read(f).split.size
  end
end

def bytes_count(files)
  files.map do |f|
    next if FileTest.directory?(f)

    File.stat(f).size
  end
end

def output(*arr)
  directory_exist = false
  arr.compact!
  totals = [0, 0, 0]
  ARGV.each_with_index do |f, i|
    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      arr.size.times { printf('%8s', '0 ') }
      directory_exist = true
    else
      arr.each_with_index do |data, num|
        directory_exist ? printf('%8s', "#{data[i]} ") : printf('%5s', "#{data[i]} ")
        totals[num] += data[i]
      end
    end
    puts f
  end
  totals.delete(0)
  totals.each do |total|
    directory_exist ? printf('%8s', "#{total} ") : printf('%5s', "#{total} ")
  end
  puts 'total'
end


  end
  puts "\n"
end

def opt_params
  opt = OptionParser.new
  params = { 'l': false, 'w': false, 'c': false }
  opt.on('-l') { |v| params[:l] = v }
  opt.on('-w') { |v| params[:w] = v }
  opt.on('-c') { |v| params[:c] = v }
  opt.parse!(ARGV)
  option = %i[l w c]
  bool_arr = option.map { |b| params[b] }
  lines = line_count(ARGV)
  words = word_count(ARGV)
  bytes = bytes_count(ARGV)
  arr = [lines, words, bytes]
  [bool_arr, arr]
end

bool_arr = opt_params[0]
arr = opt_params[1]

unless bool_arr.none?
  bool_arr.each_with_index do |b, i|
    next if b

    arr[i] = nil
  end
end

output(*arr)
