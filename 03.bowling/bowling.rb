#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_PINS = 10
ROLL_RESULT_TO_SCORE = { 'X' => 10 }.freeze

scores = ARGV[0].split(',').map { |roll_result| ROLL_RESULT_TO_SCORE.fetch(roll_result, roll_result.to_i) }

frame_ten = 10
frame_count = 1
roll_count = 0
total_score = 0
while frame_count < frame_ten # 9フレームまでループ処理
  if scores[roll_count] == MAX_PINS # ストライクなら
    total_score += scores[roll_count, 3].sum
    # total_score += sum_scores_in_range(scores, roll_count..roll_count + 2)
    roll_count += 1
    frame_count += 1
    next
  end

  frame_score = scores[roll_count, 2].sum
  # frame_score = sum_scores_in_range(scores, roll_count..roll_count + 1)
  total_score += frame_score
  total_score += scores[roll_count + 2] if frame_score == MAX_PINS # スペアなら
  roll_count += 2
  frame_count += 1
end

# 最終フレームの計算
total_score += scores[roll_count..scores.length - 1].sum
# total_score += sum_scores_in_range(scores, roll_count..scores.length - 1)

puts total_score
