require 'pry-byebug'

# frozen_string_literal: true

def random_code
  colors = %w[red green blue yellow orange]

  Array.new(4) { colors.sample }
end

def same_position?(color, secret_code, guess_code)
  secret_code.each_with_index do |secret_peg_color, secret_peg_color_index|
    guess_code.each_with_index do |guess_peg_color, guess_peg_color_index|
      return true if secret_peg_color == guess_peg_color && secret_peg_color_index == guess_peg_color_index
    end
  end

  false
end

def color_found?(color, secret_code)
  secret_code.include?(color)
end

def one_hit?(secret_code, guess_code)
  guess_code.any? { |guess_peg_color| same_position?(guess_peg_color, secret_code, guess_code) }
end

def color_guessed?(secret_code, guess_code)
  guess_code.any? { |guess_peg_color| color_found?(guess_peg_color, secret_code) }
end

def found_color(secret_code, guess_code)
  guess_code.find { |guess_peg_color| color_found?(guess_peg_color, secret_code) }
end

def color_hit_index(secret_code, guess_code)
  secret_code.each_with_index do |secret_peg_color, secret_peg_color_index|
    guess_code.each_with_index do |guess_peg_color, guess_peg_color_index|
      return guess_peg_color_index if secret_peg_color == guess_peg_color && secret_peg_color_index == guess_peg_color_index
    end
  end
end

def one_hit_removed_from(secret_code, guess_code)
  processed_secret = secret_code.reject.with_index do |_, secret_color_peg_index|
    secret_color_peg_index == color_hit_index(secret_code, guess_code) 
  end
  processed_guess = guess_code.reject.with_index do |_, guess_color_peg_index|
    guess_color_peg_index == color_hit_index(secret_code, guess_code) 
  end

  [processed_secret, processed_guess]
end

def one_color_removed_from(secret_code, guess_code)
  processed_secret = secret_code - [found_color(secret_code, guess_code)] 
  processed_guess  = guess_code  - [found_color(secret_code, guess_code)] 

  [processed_secret, processed_guess]
end

def feedback_row(secret_code, guess_code)
  processed_secret = secret_code
  processed_guess = guess_code
  result = []

  4.times do
    binding.pry

    if one_hit?(processed_secret, processed_guess)
      processed_secret, processed_guess = one_hit_removed_from(processed_secret, processed_guess)
      result << :hit
    elsif color_guessed?(processed_secret, processed_guess)
      processed_secret, processed_guess = one_color_removed_from(processed_secret, processed_guess)
      result << :correct_color
    end
  end

  result
end

def formatted_feedback(secret_code, guess_code)
  feedback_row(secret_code, guess_code).join(', ')
end

def process_guess_code(input)
  input.chomp.split(",").map(&:strip)
end

def four_hits?(secret_code, guess_code)
  feedback_row(secret_code, guess_code).count(:hit) == 4
end

def win?(secret_code, guess_code)
  four_hits?(secret_code, guess_code)
end

secret_code = %w[red red green orange]
guess_code = %w[]

until win?(secret_code, guess_code)
  puts "Enter a code: (for example: red, green, blue, yellow)"
  guess_code = process_guess_code(gets) 
  puts "Alright, here you go you cheater you: #{secret_code.join(", ")}" if guess_code == %w[show me]

  puts "Here's your feedback: #{ feedback_row(secret_code, guess_code).join(', ') }"
end
