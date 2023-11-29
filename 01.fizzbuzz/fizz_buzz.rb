# frozen_string_literal: true

(1..20).each { |number|
  if (number % 3).zero? && (number % 5).zero?
    puts 'FizzBuzz'
  elsif (number % 3).zero?
    puts 'Fizz'
  elsif (number % 5).zero?
    puts 'Buzz'
  else
    puts number
  end
}
