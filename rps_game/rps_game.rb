require_relative "player.rb"
require_relative "scoreboard.rb"

class RPSGame
  MAX_SCORE = 3
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    @scoreboard = Scoreboard.new(@human, @computer)
  end

  def play
    system "clear"
    display_welcome_message
    set_names
    loop do
      rounds
      break if play_again? == false
    end
    display_goodbye_message
  end

  def rounds
    loop do
      system "clear"
      display_score_board
      players_chose
      display_winner_of_round
      next_round? if !max_score_reached?
      break if max_score_reached?
    end
    display_score_board
    display_winner_of_game
  end

  def next_round?
    puts
    puts "(enter) for next round.."
    loop do
      input = gets
      break if input == "\n"
    end
  end

  def players_chose
    human.choose
    computer.choose
  end

  def set_names
    @human.set_name
    @computer.set_name
  end

  def play_again?
    choice = false
    loop do
      puts 'Do you want to play again? (yes/no)'
      user_input = gets.chomp.downcase
      choice = true if user_input == 'yes'
      break if %w(yes no).include?(user_input)
      puts 'invalid input.. try again'
    end
    choice
  end

  def display_score_board
    @scoreboard.display
  end

  def display_winner_of_round
    puts
    if human.move == computer.move
      puts 'Its a Tie!'
    elsif human.move > computer.move
      puts "#{@human.name} won the round!"
      @human.increase_score
    else
      puts "#{@computer.name} won the round!"
      @computer.increase_score
    end
  end

  def max_score_reached?
    !!determine_winner
  end

  def determine_winner
    if @computer.score == MAX_SCORE
      @computer.name
    elsif @human.score == MAX_SCORE
      @human.name
    else
      false
    end
  end

  def display_winner_of_game
    puts "#{determine_winner} won the game!!"
    reset_scores
  end

  def reset_scores
    @human.reset_score
    @computer.reset_score
  end

  def display_welcome_message
    puts 'Hello welcome to Rock, Paper, Scissors!'
    puts 'You play until someone has a score of 3'
  end

  def display_goodbye_message
    puts 'Goodbye!'
  end
end

RPSGame.new.play
