#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OPTIONS = {}.freeze
COLUMN_WIDTH = 8

def main
  options, file_paths = parse_params
  text_statuses = if $stdin.tty?
                    file_paths.map { |file_path| to_text_status(File.read(file_path), file_path) }
                  else
                    [to_text_status($stdin.read)]
                  end

  print_text_statuses(text_statuses)
  if text_statuses.length >= 2
    total_text_status = total_text_status(text_statuses)
    print_text_status(total_text_status)
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

def to_text_status(text, label = '')
  {
    line_count: text.lines.length,
    word_count: text.split.length,
    byte_count: text.bytesize,
    label: label
  }
end

def print_text_statuses(text_statuses)
  text_statuses.each { |text_status| print_text_status(text_status) }
end

def print_text_status(text_status)
  print text_status[:line_count].to_s.rjust(COLUMN_WIDTH)
  print text_status[:word_count].to_s.rjust(COLUMN_WIDTH)
  print text_status[:byte_count].to_s.rjust(COLUMN_WIDTH)
  print ' '
  print text_status[:label]
  puts
end

def total_text_status(text_statuses)
  {
    line_count: text_statuses.sum { |text_status| text_status[:line_count] },
    word_count: text_statuses.sum { |text_status| text_status[:word_count] },
    byte_count: text_statuses.sum { |text_status| text_status[:byte_count] },
    label: 'total'
  }
end

main
