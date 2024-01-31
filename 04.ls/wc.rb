#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

p ARGV

def line_count(files)
  files.map do |f|
    next unless FileTest.directory?(f) || FileTest.file?(f)
    next if FileTest.directory?(f)
    File.read(f).count("\n", "/[^\n]\z/")
  end
end

def word_count(files)
  files.map do |f|
    next unless FileTest.directory?(f) || FileTest.file?(f)
    next if FileTest.directory?(f)
    File.read(f).split.size
  end
end

def bytes_count(files)
  files.map do |f|
    next unless FileTest.directory?(f) || FileTest.file?(f)
    next if FileTest.directory?(f)

    File.stat(f).size
  end
end

def output(*arr)
  directory_exist = false
  arr.compact!
  totals = [0,0,0]
  ARGV.each_with_index do |f, i|
    next unless FileTest.directory?(f) || FileTest.file?(f)

    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      arr.size.times { printf("%8s", '0 ') }
      directory_exist = true
    else
      arr.each_with_index do |data, num|
        next if data.nil?

        directory_exist ? printf('%8s', "#{data[i]} ") : printf('%5s', "#{data[i]} ")
        totals[num] += data[i]
      end
    end
    puts f.to_s
  end
  totals.each do |total|
    next if total.zero?

    directory_exist ? printf('%8s', "#{total} ") : printf('%5s', "#{total} ") 
  end
  puts ' total'
end

opt = OptionParser.new
params = {'l': false, 'w': false, 'c': false}
opt.on('-l') { |v| params[:l] = v }
opt.on('-w') { |v| params[:w] = v }
opt.on('-c') { |v| params[:c] = v }
opt.parse!(ARGV)
option = [:l, :w, :c]

lines = line_count(ARGV)
words = word_count(ARGV)
bytes = bytes_count(ARGV)
arr = [lines, words, bytes]

option.each_with_index do |b, i|
  next if params[b]

  arr[i] = nil
end

output(*arr)
