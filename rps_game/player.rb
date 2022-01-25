require_relative "move.rb"

class Player
  COMPUTER_NAMES = %w(Robocop CKL34 HondaRob).freeze
  POSSIBLE_CHOICES = %w(rock paper scissor lizard spock).freeze
  attr_reader :move, :score
  attr_accessor :name

  def initialize
    @move = nil
    @score = 0
  end

  def increase_score
    @score += 1
  end

  def reset_score
    @score = 0
  end
end

class Human < Player
  def set_name
    puts 'What is your name?'
    self.name = gets.chomp
  end

  def choose
    choice = nil
    loop do
      puts "#{name} choose between Rock, Paper, Scissor, Lizard or Spock"
      choice = gets.chomp.downcase
      break if POSSIBLE_CHOICES.include?(choice)

      puts 'no valid input try again..'
    end
    puts "#{name} choose #{choice.capitalize}"
    @move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    @name = COMPUTER_NAMES.sample
    puts "The name of the Computer is #{name}"
    sleep(3)
  end

  def choose
    @move = Move.new(POSSIBLE_CHOICES.sample)
    puts "#{name} choice is : #{@move.value.capitalize}"
  end
end
