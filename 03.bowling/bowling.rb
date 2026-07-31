#!/usr/bin/env ruby
# frozen_string_literal: true

FRAME_NUMBER_IN_GAME = 10
MAX_PINS = 10
ROLL_RESULT_TO_SCORE = { 'X' => 10 }.freeze

def calc_total_score(scores)
  roll_count = 0
  total_score = 0
  FRAME_NUMBER_IN_GAME.times do
    if scores[roll_count] == MAX_PINS
      total_score += scores[roll_count, 3].sum
      roll_count += 1
    elsif scores[roll_count, 2].sum == MAX_PINS
      total_score += scores[roll_count, 3].sum
      roll_count += 2
    else
      total_score += scores[roll_count, 2].sum
      roll_count += 2
    end
  end

  total_score
end

scores = ARGV[0].split(',').map { |roll_result| ROLL_RESULT_TO_SCORE.fetch(roll_result, roll_result.to_i) }

puts calc_total_score(scores)
