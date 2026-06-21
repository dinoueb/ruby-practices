#!/usr/bin/env ruby

require 'optparse'
require 'date'

DAYS_OF_WEEK = ["日", "月", "火", "水", "木", "金", "土"]
MAX_WEEK = 6
YEAR_FORMAT_WIDTH = 13
MONTH_FORMAT_WIDTH = 8
WEEK_FORMAT_WIDTH = 22
DAY_FORMAT_WIDTH = 2

def create_monthly_calendar(first_day, last_day)
  monthly_calendar = Array.new(MAX_WEEK) { Array.new(DAYS_OF_WEEK.length) }
  
  week_count = 0
  first_day.step(last_day) do |date|
    monthly_calendar[week_count][date.wday] = date.day

    if date.saturday?
      week_count += 1
    end
  end

  monthly_calendar
end

def print_monthly_calendar(monthly_calendar, date)
  # ヘッダー
  puts "#{date.month}月".rjust(MONTH_FORMAT_WIDTH) + " " + "#{date.year}".ljust(YEAR_FORMAT_WIDTH) # ljustの右側へのスペースの追加はcalコマンドの出力結果に合わせたため
  puts DAYS_OF_WEEK.join(" ").ljust(15) # ljustの右側へのスペースの追加はcalコマンドの出力結果に合わせたため

  monthly_calendar.each do |week|
    puts week.map { |day| day.to_s.rjust(DAY_FORMAT_WIDTH) }.join(" ").ljust(WEEK_FORMAT_WIDTH) # ljustの右側へのスペースの追加はcalコマンドの出力結果に合わせたため
  end
end

params = ARGV.getopts("y:", "m:")
year = params["y"].nil? ? Date.today.year: params["y"].to_i
month = params["m"].nil? ? Date.today.month: params["m"].to_i

first_day = Date.new(year, month)
last_day = Date.new(year, month, -1)

monthly_calendar = create_monthly_calendar(first_day, last_day)
print_monthly_calendar(monthly_calendar, first_day)
