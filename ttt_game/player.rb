require_relative "info_share.rb"

class Player
  include Info_share
  
  attr_accessor :score
  
  def initialize(board)
    @board = board
    @score = 0
  end

  def reset_score
    @score = 0
  end

  def score=(value)
    @score = value
  end

end

class Human < Player

  def mark 
    valid_input = @board.possible_choices
    user_input = nil
    promt("please mark a square.. possible inputs are #{valid_input}")
    loop do 
      user_input = gets.chomp.to_i
      break if valid_input.include?(user_input)
      promt("no valid input.. possible inputs are #{valid_input}")
    end
    @board.human_square = user_input
    @board.set_human_on_brd
  end

  def score=(value)
    @board.human_score = value
    super(value)
  end
end


class Computer < Player
  
  def mark
    promt("computer marks a square..")
    sleep(2)
    @board.computer_square = @board.possible_choices.sample 
    @board.set_computer_on_brd
  end

  def score=(value)
    @board.computer_score = value
    super(value)
  end

end
