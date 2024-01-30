#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

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
  totals = [0,0,0]
  ARGV.each_with_index do |f, i|
    next unless FileTest.directory?(f) || FileTest.file?(f)

    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      3.times { printf('%8s', '0 ') }
    else
      arr.each_with_index do |data, num|
        printf('%8s', "#{data[i]} ")
        totals[num] += data[i]
      end
    end
    puts "#{f}"
  end
  totals.each { |total| printf('%8s', "#{total} ") }
  puts ' total'
end

opt = OptionParser.new
params = {}
opt.on('-l') { |v| params[:l] = v }
opt.on('-w') { |v| params[:w] = v }
opt.on('-c') { |v| params[:c] = v }

lines = line_count(ARGV)
words = word_count(ARGV)
bytes = bytes_count(ARGV)
arr = [lines, words, bytes]

output(*arr)
