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
  file_names = list_file_names(directory_path, options)

  if options[:long_format]
    file_statuses = file_names.map do |file_name|
      file_path = File.join(directory_path, file_name)
      to_file_status(file_path)
    end

    print_file_statuses(file_statuses)
  else
    print_file_names(file_names)
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

def list_file_names(directory_path, options)
  file_names = Dir.entries(directory_path).sort
  filtered_file_names = options[:all] ? file_names : file_names.reject { |file_name| file_name.start_with?('.') }
  options[:reverse] ? filtered_file_names.reverse : filtered_file_names
end

def to_file_status(file_path)
  file_status = File.lstat(file_path)

  {
    path: file_path,
    block_count: file_status.blocks,
    entry_type: FILE_TYPES[file_status.ftype],
    permission: parse_permission(file_status.mode),
    link_count: file_status.nlink,
    owner_name: Etc.getpwuid(file_status.uid).name,
    group_name: Etc.getgrgid(file_status.gid).name,
    bytes: file_status.size,
    modification_time: file_status.mtime
  }
end

def print_file_statuses(file_statuses)
  column_widths = calc_column_widths(file_statuses)

  puts "total #{file_statuses.sum { |file_status| file_status[:block_count] }}"
  file_statuses.each do |file_status|
    print file_status[:entry_type]
    print file_status[:permission]
    print ' '
    print file_status[:link_count].to_s.rjust(column_widths[:link_count])
    print ' '
    print file_status[:owner_name].rjust(column_widths[:owner_name])
    print '  '
    print file_status[:group_name].rjust(column_widths[:group_name])
    print '  '
    print file_status[:bytes].to_s.rjust(column_widths[:bytes])
    print ' '
    print file_status[:modification_time].strftime('%_m %e %R')
    print ' '
    print File.basename(file_status[:path])
    print " -> #{File.readlink(file_status[:path])}" if File.symlink?(file_status[:path])
    puts
  end
end

def calc_column_widths(file_statuses)
  {
    link_count: file_statuses.map { |file_status| file_status[:link_count].to_s.length }.max,
    owner_name: file_statuses.map { |file_status| file_status[:owner_name].length }.max,
    group_name: file_statuses.map { |file_status| file_status[:group_name].length }.max,
    bytes: file_statuses.map { |file_status| file_status[:bytes].to_s.length }.max
  }
end

def parse_permission(file_mode)
  owner = parse_permission_triplets(file_mode[6..8], file_mode[11], 's')
  group = parse_permission_triplets(file_mode[3..5], file_mode[10], 's')
  other = parse_permission_triplets(file_mode[0..2], file_mode[9], 't')

  owner + group + other
end

def parse_permission_triplets(triplets, special, special_symbol)
  r = triplets[2] == 1 ? 'r' : '-'
  w = triplets[1] == 1 ? 'w' : '-'
  has_special = special == 1
  x = if triplets[0] == 1
        has_special ? special_symbol.downcase : 'x'
      else
        has_special ? special_symbol.upcase : '-'
      end

  r + w + x
end

def print_file_names(file_names)
  return if file_names.empty?

  column_width = calc_column_width(file_names)
  max_row = file_names.length.ceildiv(MAX_COLUMN)
  max_row.times do |row_number|
    MAX_COLUMN.times do |column_number|
      index = row_number + max_row * column_number
      break if index >= file_names.length

      if column_number != MAX_COLUMN - 1
        print file_names[index].ljust(column_width)
      else
        print file_names[index]
      end
    end
    puts
  end
end

def calc_column_width(file_names)
  max_length = file_names.map(&:length).max
  max_length.ceildiv(COLUMN_WIDTH_MULTIPLIER) * COLUMN_WIDTH_MULTIPLIER
end

main
