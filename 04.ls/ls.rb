#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

OPTIONS = {
  '-a' => :all,
  '-r' => :reverse,
  '-l' => :long_format
}.freeze
FILE_TYPES = {
  'file' => '-',
  'directory' => 'd',
  'characterSpecial' => 'c',
  'blockSpecial' => 'b',
  'fifo' => 'p',
  'link' => 'l',
  'socket' => 's',
  'unknown' => 'w'
}.freeze
COLUMN_WIDTH_MULTIPLIER = 8
MAX_COLUMN = 3

def main
  options, directory_path = parse_params
  directory_path ||= Dir.pwd
  target_file_names = Dir.entries(directory_path).sort

  processed_file_names = apply_options(target_file_names, options)

  if options[:long_format]
    file_paths = processed_file_names.map { |file_name| File.join(directory_path, file_name) }
    print_file_status(file_paths)
  else
    print_file_names(processed_file_names)
  end
end

def parse_params
  options = {}

  option_parser = OptionParser.new
  OPTIONS.each do |option, option_name|
    option_parser.on(option) { options[option_name] = true }
  end
  directory_paths = option_parser.parse(ARGV)
  [options, directory_paths[0]]
end

def apply_options(files, options)
  filtered_files = options[:all] ? files : files.reject { |file| file.start_with?('.') }
  options[:reverse] ? filtered_files.reverse : filtered_files
end

def print_file_status(file_paths)
  file_statuses = file_paths.to_h { |file_path| [file_path, File.lstat(file_path)] }
  column_widths = calc_column_widths(file_statuses.values)

  puts "total #{file_statuses.values.sum(&:blocks)}"
  file_statuses.each do |file_path, file_status|
    print FILE_TYPES[file_status.ftype] + parse_permission(file_status.mode)
    print ' '
    print file_status.nlink.to_s.rjust(column_widths[:links])
    print ' '
    print Etc.getpwuid(file_status.uid).name.rjust(column_widths[:owner_name])
    print '  '
    print Etc.getgrgid(file_status.gid).name.rjust(column_widths[:group_name])
    print '  '
    print file_status.size.to_s.rjust(column_widths[:bytes])
    print ' '
    print file_status.mtime.strftime('%_m %e %R')
    print ' '
    print File.basename(file_path)
    print " -> #{File.readlink(file_path)}" if file_status.symlink?
    puts
  end
end

def calc_column_widths(file_statuses)
  {
    links: file_statuses.map { |file_status| file_status.nlink.to_s.length }.max,
    owner_name: file_statuses.map { |file_status| Etc.getpwuid(file_status.uid).name.length }.max,
    group_name: file_statuses.map { |file_status| Etc.getgrgid(file_status.gid).name.length }.max,
    bytes: file_statuses.map { |file_status| file_status.size.to_s.length }.max
  }
end

def parse_permission(file_mode)
  owner = parse_owner_permission(file_mode)
  group = parse_group_permission(file_mode)
  other = parse_other_permission(file_mode)

  owner + group + other
end

def parse_owner_permission(file_mode)
  r = file_mode[8] == 1 ? 'r' : '-'
  w = file_mode[7] == 1 ? 'w' : '-'
  has_set_user_id = file_mode[11] == 1
  x = if file_mode[6] == 1
        has_set_user_id ? 's' : 'x'
      else
        has_set_user_id ? 'S' : '-'
      end

  r + w + x
end

def parse_group_permission(file_mode)
  r = file_mode[5] == 1 ? 'r' : '-'
  w = file_mode[4] == 1 ? 'w' : '-'
  has_set_group_id = file_mode[10] == 1
  x = if file_mode[3] == 1
        has_set_group_id ? 's' : 'x'
      else
        has_set_group_id ? 'S' : '-'
      end

  r + w + x
end

def parse_other_permission(file_mode)
  r = file_mode[2] == 1 ? 'r' : '-'
  w = file_mode[1] == 1 ? 'w' : '-'
  has_sticky_bit = file_mode[9] == 1
  x = if file_mode[0] == 1
        has_sticky_bit ? 't' : 'x'
      else
        has_sticky_bit ? 'T' : '-'
      end

  r + w + x
end

def print_file_names(files)
  return if files.empty?

  column_width = calc_column_width(files)
  max_row = files.length.ceildiv(MAX_COLUMN)
  max_row.times do |row_number|
    MAX_COLUMN.times do |column_number|
      index = row_number + max_row * column_number
      break if index >= files.length

      if column_number != MAX_COLUMN - 1
        print files[index].ljust(column_width)
      else
        print files[index]
      end
    end
    puts
  end
end

def calc_column_width(files)
  max_length = files.map(&:length).max
  max_length.ceildiv(COLUMN_WIDTH_MULTIPLIER) * COLUMN_WIDTH_MULTIPLIER
end

main
