require "yaml"

require_relative "player"
require_relative "board.rb"
require_relative "info_share.rb"

MESSAGE = YAML.load_file("messages.yml")
WINNING_LINES = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],
[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

class TTT
  include Info_share
  @@winner = nil

  def initialize
    @board = Board.new
    @human = Human.new(@board)
    @computer = Computer.new(@board)
  end

  def play
    system "clear"
    promt(MESSAGE['welcome'])
    sleep(2)
    loop do 
      players_mark
      display_congrat
      break if play_again?
    end
    promt(MESSAGE['goodbye'])
  end	
  
  def players_mark
    loop do
      @board.display
      @human.mark
      break if @board.full? || someone_won?
      
      @board.display
      @computer.mark
      break if @board.full? || someone_won?
      
    end
  end

  def someone_won?
    if !!determine_winner
      @board.display
      true
    else
      false
    end

  end

  def determine_winner
    WINNING_LINES.each do |line|
      if @board.brd[line[0]-1] == "X" && @board.brd[line[1]-1] == "X" && @board.brd[line[2]-1] == "X"
        @human.score += 1
        return @@winner = "Human"
      elsif @board.brd[line[0]-1] == "O" && @board.brd[line[1]-1] == "O" && @board.brd[line[2]-1] == "O"
        @computer.score += 1
        return @@winner = "Computer"
      end
    end
    nil
  end


  def display_congrat
    promt("congrat #{@@winner} #{MESSAGE['congrat']}")
  end

  def play_again?
    promt(MESSAGE['play_again?'])
    user_input = nil
    loop do 
      user_input = gets.chomp
      break if ['y','n'].include?(user_input)
      promt(MESSAGE['play_again_invalid_input']) 
    end
    return true if user_input == 'n'
    @board.reset 
    false
  end
    
end





TTT.new.play