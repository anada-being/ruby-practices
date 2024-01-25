#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def line_count(files)
  total = 0
  files.map do |f|
    next unless FileTest.directory?(f) || FileTest.file?(f)

    if FileTest.directory?(f)
      puts "wc: #{f}: Is a directory"
      printf('%7d', '0')
    else
      line = File.read(f).count("\n", "/[^\n]\z/")
      printf('%7d', line)
      total += line
    end
    puts " #{f}"
  end
  printf('%7d', total)
  puts ' total'
end

opt = OptionParser.new
params = {}
opt.on('-l') { |v| params[:l] = v }
opt.parse(ARGV)

line_count(ARGV) if params[:l]
