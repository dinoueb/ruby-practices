#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_PINS = 10
ROLL_RESULT_TO_SCORE = { 'X' => 10 }.freeze

scores = ARGV[0].split(',').map { |roll_result| ROLL_RESULT_TO_SCORE.fetch(roll_result, roll_result.to_i) }

roll_count = 0
total_score = 0
(1..9).each do # 9フレームまでループ処理
  if scores[roll_count] == MAX_PINS # ストライクなら
    total_score += scores[roll_count, 3].sum
    roll_count += 1
    next
  end

  frame_score = scores[roll_count, 2].sum
  total_score += frame_score
  total_score += scores[roll_count + 2] if frame_score == MAX_PINS # スペアなら
  roll_count += 2
end

# 最終フレームの計算
total_score += scores[roll_count..scores.length - 1].sum

puts total_score
