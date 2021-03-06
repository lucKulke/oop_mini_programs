# frozen_string_literal: true

require 'yaml'
MESSAGE = YAML.load_file('messages.yml')
HUMAN_SYMBOL = 'X'
COMPUTER_SYMBOL = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7],
                 [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]].freeze

module Displayable
  def promt(message)
    puts message
  end

  def clear_terminal
    system 'clear'
  end
end

module DetermineWinner
  def determine_winner
    winner = nil
    [HUMAN_SYMBOL, COMPUTER_SYMBOL].each do |symbol|
      winner = check_lines(winner, symbol)
    end
    winner
  end

  def check_lines(winner, symbol)
    WINNING_LINES.each do |line|
      winner = symbol if @board.brd[line[0]] == symbol && @board.brd[line[1]] == symbol && @board.brd[line[2]] == symbol
    end
    winner
  end
end

class Board
  include Displayable
  attr_reader :brd
  attr_accessor :rounds, :human_score, :computer_score

  def initialize # datastructure of the board is a hash
    @brd = {}
    new_game
  end

  def reset # set up a hash with the positions as key and the boxes as values {1 => ' ', 2 => ' ', ...}
    9.times { |step| @brd[step + 1] = ' ' }
  end

  def new_game
    reset
    @human_score = 0
    @computer_score = 0
    @rounds = 0
  end

  def possible_choices
    @brd.select { |_, box| box == ' ' }
  end

  def full?
    @brd.none? { |_, box| box == ' ' }
  end

  def mark(position, marker) # set the symbol of the current marker on the board
    @brd[position] = marker == :human ? HUMAN_SYMBOL : COMPUTER_SYMBOL
  end

  def display
    clear_terminal

    puts ' Try to beat the Computer!!!'
    puts ' ---------------------------'
    puts "        * Round #{[rounds + 1]} *           "
    puts ''
    puts 'Player_points | Computer_points '
    puts '-------------------------------'
    puts "       #{human_score}      |     #{computer_score}"
    puts '  ___________________________'
    puts ''
    puts "   You're a X. Computer is O."
    puts '   ************************'
    puts '   *        BOARD         *'
    puts '   *        -----         *'
    puts '   *                      *'
    puts '   *       |     |        *'
    puts "   *    #{@brd[1]}  |  #{@brd[2]}  |  #{@brd[3]}     *"
    puts '   *       |     |        *'
    puts '   *  -----------------   *'
    puts '   *       |     |        *'
    puts "   *    #{@brd[4]}  |  #{@brd[5]}  |  #{@brd[6]}     *"
    puts '   *       |     |        *'
    puts '   *  -----------------   *'
    puts '   *       |     |        *'
    puts "   *    #{@brd[7]}  |  #{@brd[8]}  |  #{@brd[9]}     *"
    puts '   *       |     |        *'
    puts '   *                      *'
    puts '   ************************'
  end
end

#------------------------------------------------

class Player
  include DetermineWinner
  include Displayable

  def initialize(board)
    @board = board
  end
end

class Human < Player
  def mark
    valid_input = @board.possible_choices.keys
    user_choice = nil
    promt(MESSAGE['human_mark'] + " #{valid_input}")
    loop do
      user_choice = gets.chomp.to_i
      break if valid_input.include?(user_choice)

      promt(MESSAGE['human_mark_invalid_input'] + " #{valid_input}")
    end
    @board.mark(user_choice, :human)
  end
end

class Computer < Player
  def mark
    best_score = -1000
    best_move = 0
    board = @board.brd
    board.keys.each do |position|
      next unless board[position] == ' '

      board[position] = COMPUTER_SYMBOL
      score = minimax(board, false) # computer calls minimax allgorithm check wich move is the best based on the score
      board[position] = ' '
      if score > best_score # take the lowest score from the minimax allgorithm as best score
        best_score = score
        best_move = position
      end
    end
    promt(MESSAGE['computer_mark'])
    sleep(2)
    @board.mark(best_move, 'Computer')
  end

  private

  def minimax(board, is_maximizing)             # minimax algorithm explanation :
    return 1 if minimax_winner == 'Computer'    # the computer plays the game against itself to the
    return -1 if minimax_winner == 'Human'      # end in all possible ways and then
    return 0 if @board.full?                    # gives all moves scores

    if is_maximizing
      best_score = -1000
      board.keys.each do |position|
        next unless board[position] == ' '
        board[position] = COMPUTER_SYMBOL
        score = minimax(board, false)
        board[position] = ' '
        best_score = score if score > best_score
      end
    else
      best_score = 1000
      board.keys.each do |position|
        next unless board[position] == ' '
        board[position] = HUMAN_SYMBOL
        score = minimax(board, true)
        board[position] = ' '
        best_score = score if score < best_score
      end
    end
    best_score
  end

  def minimax_winner
    winner = determine_winner
    return winner == HUMAN_SYMBOL ? 'Human' : 'Computer' if winner

    nil
  end
end

#----------------------------------------------

class TTTgame
  include DetermineWinner
  include Displayable
  attr_accessor :winner_of_round, :winner_of_game, :rounds_to_play

  def initialize
    @board = Board.new
    @human = Human.new(@board)
    @computer = Computer.new(@board)
  end

  def play
    clear_terminal
    promt(MESSAGE['welcome'])
    loop do
      main_game
      break unless play_again?
    end
    clear_terminal
    promt(MESSAGE['goodbye'])
  end

  private

  def main_game
    set_rounds
    clear_terminal
    loop do
      round
      break if @board.rounds == @rounds_to_play
    end
    determine_winner_of_game
    display_congrat_game
  end

  def round
    loop do
      @board.display
      players_mark
      break if @board.full? || someone_won?
    end
    @board.display
    display_congrat_round
    @board.rounds += 1
    @board.reset
  end

  def play_again?
    promt(MESSAGE['play_again?'])
    loop do
      user_input = gets.chomp.downcase
      if %w[y n].include?(user_input)
        return @board.new_game if user_input == 'y'

        break
      end
      promt(MESSAGE['play_again_invalid_input'])
    end
    false
  end

  def set_scores
    @board.human_score += 1 if @winner_of_round == 'Human'
    @board.computer_score += 1 if @winner_of_round == 'Computer'
  end

  def determine_winner_of_game
    return nil if @board.human_score == @board.computer_score

    @winner_of_game = @board.human_score > @board.computer_score ? 'Human' : 'Computer'
  end

  def display_congrat_game
    puts
    if determine_winner_of_game
      promt(@winner_of_game + MESSAGE['congrat_game'])
    else
      promt(MESSAGE['game_tie'])
    end
    puts
  end

  def display_congrat_round
    if @board.full?
      promt(MESSAGE['round_tie'])
    else
      promt(@winner_of_round + MESSAGE['congrat_round'])
      set_scores
    end
    sleep(3)
  end

  def set_rounds
    promt(MESSAGE['set_rounds'])
    loop do
      @rounds_to_play = gets.chomp.to_i
      break if (1..10).include?(rounds_to_play)

      promt(MESSAGE['set_rounds_invalid_input'])
    end
  end

  def players_mark
    @human.mark
    @board.display
    return if @board.full?

    @computer.mark
  end

  def someone_won?
    !!determine_winner_of_round
  end

  def determine_winner_of_round
    winner = determine_winner
    return @winner_of_round = winner == HUMAN_SYMBOL ? 'Human' : 'Computer' if winner

    nil
  end
end

TTTgame.new.play
