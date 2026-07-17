#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OPTION_TO_NAME = {
  '-a' => :all,
  '-r' => :reverse
}.freeze
COLUMN_WIDTH_MULTIPLIER = 8
MAX_COLUMN = 3

def main
  options, directory_path = parse_params
  directory_path ||= Dir.pwd
  target_files = Dir.entries(directory_path).sort

  processed_files = apply_options(target_files, options)

  print_files(processed_files)
end

def parse_params
  options = {}

  option_parser = OptionParser.new
  OPTION_TO_NAME.each do |option, option_name|
    option_parser.on(option) { options[option_name] = true }
  end
  directory_paths = option_parser.parse(ARGV)
  [options, directory_paths[0]]
end

def apply_options(files, options)
  filtered_files = options[:all] ? files : files.reject { |file| file.start_with?('.') }
  options[:reverse] ? filtered_files.reverse : filtered_files
end

def print_files(files)
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
