#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OPTIONS = ['-a'].freeze
COLUMN_WIDTH_MULTIPLIER = 8
MAX_COLUMN = 3

def main
  params = parse_params
  directory_path = ARGV[0] || Dir.pwd
  target_files = params[:a] ? Dir.entries(directory_path).sort : Dir.glob('*', base: directory_path)

  print_files(target_files)
end

def parse_params
  params = {}

  option_parser = OptionParser.new
  OPTIONS.each { |option| option_parser.on(option) }
  option_parser.parse!(ARGV, into: params)
  params
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
