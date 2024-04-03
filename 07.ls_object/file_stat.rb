# frozen_string_literal: true

require 'etc'

class FileStat
  def initialize(path)
    @file_name = path
    @stat = File.stat(path)
  end

  def build_data
    {
      type_and_mode: "#{format_type}#{format_mode}",
      nlink: @stat.nlink.to_s,
      user: Etc.getpwuid(@stat.uid).name,
      group: Etc.getgrgid(@stat.gid).name,
      size: @stat.size.to_s,
      mtime: @stat.mtime.strftime('%b %e %H:%M'),
      basename: @file_name,
      blocks: @stat.blocks
    }
  end

  private

  def format_type
    '-'
  end

  def format_mode
    digits = @stat.mode.to_s(8)[-3..]
    digits.gsub(/./, MODE_TABLE)
  end
end
