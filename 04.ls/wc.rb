#!/usr/bin/env ruby

# frozen_string_literal: true

def line_count(files)
  total = 0
  files.map do |f|
    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      printf("%7d",'0')
    else
      line = File.read(f).count("\n", "/[^\n]\z/")
      printf("%7s","#{line}")
      total += line
    end
    puts " #{f}"
  end
  printf("%7s","#{total}")
  puts " total"
end

line_count(ARGV)
