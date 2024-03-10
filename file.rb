require 'pry-byebug'

# frozen_string_literal: true

def colors
  %w[red green blue yellow orange pink]
end

def random_code
  Array.new(4) { colors.sample }
end

def same_position?(color, secret_code, guess_code)
  secret_code.each_with_index do |secret_peg_color, secret_peg_color_index|
    guess_code.each_with_index do |guess_peg_color, guess_peg_color_index|
      return true if secret_peg_color == guess_peg_color && secret_peg_color_index == guess_peg_color_index && guess_peg_color != :placeholder
    end
  end

  false
end

def color_found?(color, secret_code)
  secret_code.include?(color) && color != :placeholder
end

def any_hit?(secret_code, guess_code)

  guess_code.any? do |guess_peg_color| 
    # binding.pry if secret_code.count(:placeholder) == 2

    same_position?(guess_peg_color, secret_code, guess_code) 
  end
end

def color_guessed?(secret_code, guess_code)
  guess_code.any? { |guess_peg_color| color_found?(guess_peg_color, secret_code) }
end

def found_color_and_index(secret_code, guess_code)
  [
    guess_code.find { |guess_peg_color| color_found?(guess_peg_color, secret_code) },
    guess_code.index { |guess_peg_color| color_found?(guess_peg_color, secret_code) }
  ]
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
  color, guess_index = found_color_and_index(secret_code, guess_code)
  guess_code[guess_index] = :placeholder
  secret_code[secret_code.index(color)] = :placeholder

  [secret_code, guess_code]
end

def feedback_row(secret_code, guess_code, debug = false)
  processed_secret, processed_guess = secret_code.dup , guess_code.dup

  result = (1..4).reduce([]) do |result, _|
    binding.pry if debug

    if any_hit?(processed_secret, processed_guess)
      processed_secret, processed_guess = one_hit_removed_from(processed_secret, processed_guess)
      result << :hit
    elsif color_guessed?(processed_secret, processed_guess)
      processed_secret, processed_guess = one_color_removed_from(processed_secret, processed_guess)
      result << :correct_color
    end

    result
  end
end

def formatted_feedback(secret_code, guess_code)
  feedback_row(secret_code, guess_code).join(', ')
end

def process_code(input)
  input.chomp.split(",").map(&:strip)
end

def process_code(input)
  input.chomp.split(",").map(&:strip)
end

def process_feedback(input)
  process_code(input).map(&:to_sym).map do |peg|
    case peg
    when :h
      :hit
    when :cc
      :correct_color
    end
  end
end

def four_hits?(secret_code, guess_code)
  feedback_row(secret_code, guess_code).count(:hit) == 4
end

def win?(secret_code, guess_code)
  four_hits?(secret_code, guess_code)
end

def codebreaker?(input)
  input.downcase.to_sym == :codebreaker
end

def codemaker?(input)
  input.downcase.to_sym == :codemaker
end

def choose_game_mode
  puts "Do you wanna be the one who makes the secret code or the one who breaks it? (input codemaker or codebreaker)"
  game_mode = gets.chomp

  if codebreaker?(game_mode)
    codebreaker_game
  elsif codemaker?(game_mode)
    codemaker_game
  else
    choose_game_mode
  end
end

def codebreaker_game
  secret_code = random_code
  guess_code = []

  until win?(secret_code, guess_code)
    puts "Enter a code: (for example: red, green, blue, yellow)"
    guess_code = process_code(gets) 

    puts "Alright, here you go you cheater you: #{secret_code.join(", ")}" if guess_code == %w[show me]

    puts "Here's your feedback: #{ feedback_row(secret_code, guess_code).join(', ') }"
  end

  puts "You win!"
end

def number_to_code_mapping
  { 1 => "red",
    2 => "green",
    3 => "blue",
    4 => "yellow",
    5 => "orange",
    6 => "pink"
  }
end

class Integer
  def to_a
    to_s.chars.map(&:to_i)
  end
end

def candidate_codes
  (1111..6666).to_a.select do |number_code|
    number_code.to_a.all? { |number| number.between?(1, 6) }
  end.map do |number_code| 
    number_code.to_a.map { |number| number_to_code_mapping[number] } 
  end
end

def make_guess(player_feedback = nil, processed_set = nil, guess_code = nil)
  return [ colors[0], colors[0], colors[1], colors[1] ] unless player_feedback

  processed_set.reject! do |candidate_code| 
    temp = feedback_row(guess_code, candidate_code).sort 
    temp != player_feedback.sort
  end

  processed_set.shift
end

def codemaker_game
  puts "" 
  puts "Enter a secret code (for example: red, green, blue, yellow)"
  secret_code = process_code(gets) 
  guess_code = make_guess 

  processed_set = candidate_codes 

  puts "" 
  puts "Here's the computer's first guess:"
  puts guess_code.join(", ")

  until win?(secret_code, guess_code)
    puts "" 
    puts "Computer trying to crack your code..."
    puts "" 

    puts "Provide feedback for the computer guess code (for example: hit, hit, correct_color, correct_color)"
    player_feedback = process_feedback(gets)

    guess_code = make_guess(player_feedback, processed_set, guess_code)

    puts "" 
    puts "Here's the computer's new guess:"
    puts guess_code.join(", ")
  end
  
  puts "Computer cracked the code!"
end

choose_game_mode
