# frozen_string_literal: true

require 'etc'

class FileAndDirectory
  attr_reader :name

  def initialize(path, filename)
    @path = "#{path}/#{filename}"
    @name = filename
    @stat = File.stat(path)
  end

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

  def key_size(key)
    keys = {
      'nlink' => nlink.size,
      'user' => user.size,
      'group' => group.size,
      'size' => file_size.size,
      'mtime' => mtime.size,
      'blocks' => blocks.size
    }
    keys[key]
  end

  def type_and_mode 
    "#{format_type}#{format_mode}"
  end

  def nlink
    @stat.nlink.to_s
  end

  def user
    Etc.getpwuid(@stat.uid).name
  end

  def group
    Etc.getgrgid(@stat.gid).name
  end

  def file_size
    @stat.size.to_s
  end

  def mtime
    @stat.mtime.strftime('%b %e %H:%M')
  end

  def blocks
    @stat.blocks
  end

  private

  def format_type
    File.file?(@path) ? 'f' : 'd'
  end

  def format_mode
    digits = @stat.mode.to_s(8)[-3..]
    digits.gsub(/./, MODE_TABLE)
  end
end
