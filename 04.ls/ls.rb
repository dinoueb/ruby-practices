#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OPTIONS = {
  '-a' => :all,
  '-r' => :reverse
}.freeze
COLUMN_WIDTH_MULTIPLIER = 8
MAX_COLUMN = 3

def main
  parsed_params = parse_params
  directory_path = parse_params[:directory_path] || Dir.pwd
  target_files = Dir.entries(directory_path).sort

  target_files = apply_params(target_files, parsed_params)

  print_files(target_files)
end

def parse_params
  parsed_params = {}

  option_parser = OptionParser.new
  OPTIONS.each do |option, option_name|
    option_parser.on(option) { parsed_params[option_name] = true }
  end
  directory_paths = option_parser.parse(ARGV)
  parsed_params.merge(directory_path: directory_paths[0])
end

def apply_params(files, parsed_params)
  copied_files = files.clone
  copied_files = copied_files.reject { |file| file.start_with?('.') } unless parsed_params[:all]
  copied_files = copied_files.reverse if parsed_params[:reverse]
  copied_files
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
