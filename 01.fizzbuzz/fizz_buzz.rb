# frozen_string_literal: true

number = 0
while number < 20
  number += 1
  if (number % 3).zero? && (number % 5).zero?
    puts 'FizzBuzz'
  elsif (number % 3).zero?
    puts 'Fizz'
  elsif (number % 5).zero?
    puts 'Buzz'
  else
    puts number
  end
end
