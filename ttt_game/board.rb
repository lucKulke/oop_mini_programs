require_relative "displayable.rb"

SYMBOL_COMPUTER = 'O'
SYMBOL_PLAYER = 'X'

class Board
  
  include Displayable
  attr_accessor :computer_square, :human_square, :human_score, :computer_score, :rounds
  attr_reader :brd

  def initialize
    self.human_score = 0
    self.computer_score = 0
    @brd = []
    9.times{ @brd << " "}
  end
    

  def set_computer_on_brd
    @brd[computer_square-1] = SYMBOL_COMPUTER
  end
  
  def set_human_on_brd
    @brd[human_square-1] = SYMBOL_PLAYER
  end

  def possible_choices
    possible_choices = []
    @brd.each_with_index do |square, index|
      if square == " "
        possible_choices << index + 1
      end
    end
    possible_choices
  end

  def reset 
    9.times{ |index| brd[index] = " "}
  end

  
  def display
    system "clear"
    
    puts "Try to beat the Computer!!!"
    puts "---------------------------"
    puts "Round #{}            "
    puts ""
    puts "Player_points | Computer_points "                  
    puts "--------------------------------"
    puts "       #{human_score}      |     #{computer_score}"
    puts "___________________________"
    puts ""
    puts "You're a X. Computer is O."
    puts "************************"
    puts "*        BOARD         *"
    puts "*        -----         *"
    puts "*                      *"        
    puts "*       |     |        *"
    puts "*    #{brd[0]}  |  #{brd[1]}  |  #{brd[2]}     *"	    
    puts "*       |     |        *"
    puts "*  -----------------   *"
    puts "*       |     |        *"
    puts "*    #{brd[3]}  |  #{brd[4]}  |  #{brd[5]}     *"
    puts "*       |     |        *"
    puts "*  -----------------   *"
    puts "*       |     |        *"
    puts "*    #{brd[6]}  |  #{brd[7]}  |  #{brd[8]}     *"
    puts "*       |     |        *"
    puts "*                      *"
    puts "************************"
  end

  def full?
    possible_choices.empty?
  end
end