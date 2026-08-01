#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OPTIONS = {}.freeze
COLUMN_WIDTH = 8

def main
  options, file_paths = parse_params
  file_statuses = file_paths.map { |file_path| to_file_status(file_path) }
  print_file_statuses(file_statuses)
  if file_statuses.length >= 2
    total_counts = total_counts(file_statuses)
    print_total_counts(total_counts)
  end
end

def parse_params
  options = {}

  option_parser = OptionParser.new
  OPTIONS.each do |option_symbol, option_name|
    option_parser.on(option_symbol) { options[option_name] = true }
  end
  file_paths = option_parser.parse(ARGV)
  [options, file_paths]
end

def to_file_status(file_path)
  text = File.read(file_path)

  {
    path: file_path,
    line_count: text.lines.length,
    word_count: text.split.length,
    byte_count: text.bytesize
  }
end

def print_file_statuses(file_statuses)
  file_statuses.each do |file_status|
    print file_status[:line_count].to_s.rjust(COLUMN_WIDTH)
    print file_status[:word_count].to_s.rjust(COLUMN_WIDTH)
    print file_status[:byte_count].to_s.rjust(COLUMN_WIDTH)
    print ' '
    print file_status[:path]
    puts
  end
end

def total_counts(file_statuses)
  {
    lines: file_statuses.sum { |file_status| file_status[:line_count] },
    words: file_statuses.sum { |file_status| file_status[:word_count] },
    bytes: file_statuses.sum { |file_status| file_status[:byte_count] }
  }
end

def print_total_counts(total_counts)
  print total_counts[:lines].to_s.rjust(COLUMN_WIDTH)
  print total_counts[:words].to_s.rjust(COLUMN_WIDTH)
  print total_counts[:bytes].to_s.rjust(COLUMN_WIDTH)
  print ' total'
  puts
end

main
