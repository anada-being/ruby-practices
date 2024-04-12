# frozen_string_literal: true

require 'etc'

class FileEtc
  MODE_TABLE = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  attr_reader :name

  def initialize(filename)
    @name = filename
    @stat = File.stat(filename)
  end

  def type_and_mode
    "#{format_type}#{format_mode}"
  end

  def nlink
    @stat.nlink
  end

  def user
    Etc.getpwuid(@stat.uid).name
  end

  def group
    Etc.getgrgid(@stat.gid).name
  end

  def file_size
    @stat.size
  end

  def mtime
    @stat.mtime.strftime('%b %e %H:%M')
  end

  def blocks
    @stat.blocks
  end

  private

  def format_type
    File.file?(@name) ? 'f' : 'd'
  end

  def format_mode
    digits = @stat.mode.to_s(8)[-3..]
    digits.gsub(/./, MODE_TABLE)
  end
end
