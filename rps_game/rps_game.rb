class Player
  COMPUTER_NAMES = ["Robocop", "CKL34", "HondaRob"]
  POSSIBLE_CHOICES = ["rock", "paper", "scissor"]
  attr_reader :move
  attr_accessor :name

  def initialize
    @move = nil
  end
end

class Human < Player
  def set_name
    puts "What is your name?"
    self.name = gets.chomp
  end

  def choose
    choice = nil
    loop do
      puts "#{name} choose between Rock, Paper or Scissor"
      choice = gets.chomp.downcase
      break if POSSIBLE_CHOICES.include?(choice)
      puts "no valid input try again.."
    end
    puts "#{name} choose #{choice.capitalize}"
    @move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    @name = COMPUTER_NAMES.sample
    puts "The name of the Computer is #{name}"
  end

  def choose
    @move = Move.new(POSSIBLE_CHOICES.sample)
    puts "#{name} choice is : #{@move.value.capitalize}"
  end
end

class Move
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    case @value
    when "rock"
      other_move.scissors? ? true : false
    when "paper"
      other_move.rock? ? true : false
    when "scissors"
      other_move.paper? ? true : false
    end
  end

  def ==(other_move)
    @value == other_move.value
  end

  def scissors?
    @value == "scissor"
  end

  def rock?
    @value == "rock"
  end

  def paper?
    @value == "paper"
  end
end

class RPSGame
  MAX_SCORE = 10
  attr_accessor :human, :computer

  def initialize
    @human = Human.new()
    @computer = Computer.new()
    @score_board = Score_board.new()
  end

  def play
    display_welcome_message
    set_names
    loop do
      human.choose
      computer.choose
      display_winner_of_round
      break if play_again? == false
    end
    display_goodbye_message
  end

  private

  def rounds
    loop do
      human.choose
      computer.choose
      display_winner_of_round
      break if max_score_reached?
    end
    display_winner_of_game
  end

  def set_names
    @human.set_name
    @computer.set_name
  end

  def play_again?
    choice = false
    loop do
      puts "Do you want to play again? (yes/no)"
      user_input = gets.chomp.downcase
      choice = true if user_input == "yes"
      break if ["yes", "no"].include?(user_input)
      puts "invalid input.. try again"
    end
    choice
  end

  def display_winner_of_round
    if human.move == computer.move
      puts "Its a Tie!"
    elsif human.move > computer.move
      puts "#{@human.name} won the game!"
    else
      puts "#{@computer.name} won the game!"
    end
  end

  def display_welcome_message
    puts "Hello welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Goodbye!"
  end
end

RPSGame.new.play

# not sure where "compare" goes yet
