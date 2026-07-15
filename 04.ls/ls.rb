#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OPTIONS = {
  '-a' => :all,
  '-r' => :reverse
}.freeze
HIDDEN_FILE_REGEXP = /^\./
COLUMN_WIDTH_MULTIPLIER = 8
MAX_COLUMN = 3

def main
  params = parse_params
  directory_path = ARGV[0] || Dir.pwd
  target_files = Dir.entries(directory_path).sort

  apply_params!(target_files, params)

  print_files(target_files)
end

def parse_params
  params = {}

  option_parser = OptionParser.new
  OPTIONS.each do |option, option_name|
    option_parser.on(option) { params[option_name] = true }
  end
  option_parser.parse!(ARGV)
  params
end

def apply_params!(files, params)
  files.delete_if { |file| file.match?(HIDDEN_FILE_REGEXP) } unless params[:all]
  files.reverse! if params[:reverse]
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
