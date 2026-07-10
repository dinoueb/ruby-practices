#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_WIDTH_MULTIPLIER = 8
MAX_COLUMN = 3

def main
  target_files = Dir.glob('*')

  print_files(target_files)
end

def calc_column_width(files)
  max_filename_length = files.map(&:length).max
  max_filename_length.ceildiv(COLUMN_WIDTH_MULTIPLIER) * COLUMN_WIDTH_MULTIPLIER
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

main
