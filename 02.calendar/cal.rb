#!/usr/bin/env ruby

require 'optparse'
require 'date'

def create_monthly_calendar(first_day, last_day)
  days_in_week = 7
  max_week = 6
  
  monthly_calendar = Array.new(max_week) { Array.new(days_in_week) }
  
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
  days_of_week = ["日", "月", "火", "水", "木", "金", "土"]

  # ヘッダー
  puts "#{date.month}月".rjust(8) + " " + "#{date.year}".ljust(13) # ljustの右側へのスペースの追加はcalコマンドの出力結果に合わせたため
  puts days_of_week.join(" ").ljust(15) # ljustの右側へのスペースの追加はcalコマンドの出力結果に合わせたため

  monthly_calendar.each do |week|
    puts week.map { |day| day.to_s.rjust(2) }.join(" ").ljust(22) # ljustの右側へのスペースの追加はcalコマンドの出力結果に合わせたため
  end
end

params = ARGV.getopts("y:", "m:")
year = params["y"].nil? ? Date.today.year: params["y"].to_i
month = params["m"].nil? ? Date.today.month: params["m"].to_i

first_day = Date.new(year, month)
last_day = Date.new(year, month, -1)

monthly_calendar = create_monthly_calendar(first_day, last_day)
print_monthly_calendar(monthly_calendar, first_day)
