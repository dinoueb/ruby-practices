#!/usr/bin/env ruby
# frozen_string_literal: true

def to_score(roll_result)
  return 10 if roll_result == 'X'

  roll_result.to_i
end

def strike?(score)
  score == 10
end

def sum_scores_in_range(scores, range)
  scores[range].sum
end

def spare?(frame_score)
  frame_score == 10
end

scores = ARGV[0].split(',').map { |roll_result| to_score(roll_result) }

frame_ten = 10
frame_count = 1
roll_count = 0
total_score = 0
while frame_count < frame_ten # 9フレームまでループ処理
  if strike? scores[roll_count] # ストライクなら
    total_score += sum_scores_in_range(scores, roll_count..roll_count + 2)
    roll_count += 1
    frame_count += 1
    next
  end

  frame_score = sum_scores_in_range(scores, roll_count..roll_count + 1)
  total_score += frame_score
  total_score += scores[roll_count + 2] if spare? frame_score # スペアなら
  roll_count += 2
  frame_count += 1
end

# 最終フレームの計算
total_score += sum_scores_in_range(scores, roll_count..scores.length - 1)

puts total_score
