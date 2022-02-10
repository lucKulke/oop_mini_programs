require 'yaml'
MESSAGE = YAML.load_file('messages.yml')
CARDS = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 11 }.freeze
SUIT = ["\u2663", "\u2666", "\u2665", "\u2660"]
SPECIALCARD = 'A'
MAX = 21
DEALER_MIN = 17
#------------------------------------
module Displayable
  def promt(message)
    puts message
  end

  def clear_terminal
    system 'clear'
  end
end
#------------------------------------
class Game
  include Displayable

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @game_table = GameTable.new(@player, @dealer)
  end

  def play
    clear_terminal
    display_message('welcome')
    main_game
    display_message('goodbye')
  end

  def main_game
    loop do 
      prepares_table
      round
      break unless decision_about('game')
    end
  end

  def round
    loop do  
      deal_cards
      display_table
      participants_turn
      display_winner
      set_roundscore
      break if deck_empty?
      break unless decision_about('round')
    end
  end

  def display_winner
    winner = determine_winner
    display_message(winner)
  end

  def set_roundscore
    winner = determine_winner
    @player.roundscore += 1 if winner == 'player_won'
    @dealer.roundscore += 1 if winner == 'dealer_won'
  end
    
  def determine_winner
    if deck_empty? 
      'deck_empty'
    elsif@dealer.handscore == @player.handscore
      'nobody_won'
    elsif @dealer.handscore < @player.handscore
      return 'dealer_won' if @player.busted?
      'player_won'
    elsif @player.handscore < @dealer.handscore
      return 'player_won' if @dealer.busted?
      'dealer_won'
    end
  end
  
  def participants_turn
    @game_table.whose_turn = @player
    return if !players_turn
    @game_table.whose_turn  = @dealer
    return if !dealers_turn 
  end

  def players_turn
    players_decision = nil
    loop do 
      return false if @player.busted? || deck_empty? 
      players_decision = decision_about('hit_or_stay', :turn) ? :hit : :stay 
      break if players_decision == :stay
      draw_card(@player)
    end
    players_decision
  end

  def dealers_turn
    display_table
    loop do
      break if @dealer.over_min?
      draw_card(@dealer)
      return false if @dealer.busted? 
    end
  end

  def draw_card(participant)
    display_table
    sleep (2) if participant == @dealer 
    participant.hand << @game_table.deck.cards.shift
    display_table
  end

  def deck_empty?
    @game_table.deck.cards.size < 5
  end

  def decision_about(decision, aktion=:loop_break)
    aktion == :loop_break ? ask_for_decision('y', 'n', decision) : ask_for_decision('h', 's', decision) 
  end

  def ask_for_decision(answer_a, answer_b, decision)
    display_message(decision)
    decision = nil
    loop do 
      decision = gets.chomp.downcase[0]
      break if [answer_a, answer_b].include?(decision)
      display_message('invalid_input')
    end
    decision == answer_a
  end

  def deal_cards
    @game_table.new_round
    2.times do 
      [@player, @dealer].each{ |participant| participant.hand << @game_table.deck.cards.shift}
    end
  end

  def prepares_table
    sleep(1)
    display_message('prepare_table')
    sleep(2)
    @game_table.whose_turn = @player
    @game_table.prepare
  end

  def display_table
    @game_table.display
  end

  def display_message(status)
    puts 
    promt(MESSAGE[status])
  end
end
#------------------------------------
class GameTable
  include Displayable
  attr_accessor :deck, :whose_turn, :start_of_round
  
  def initialize(player, dealer)
    @player = player
    @dealer = dealer
    @deck = Deck.new
  end

  def display
    clear_terminal
    puts "_________Twenty-One__________"
    puts ""
    puts "Deck size = #{@deck.cards.size}"
    puts ""
    puts "      PlayerP. |  DealerP. "
    puts "-----------------------------"
    puts "total     #{@player.roundscore}          #{@dealer.roundscore}"
    puts "hand      #{@player.handscore}          #{dealers_handscore}" 
    puts "_____________________________"
    puts ""
    puts "Dealer:"
    puts "cards => #{dealers_hand}"
    puts ""
    puts "Player:"
    puts "cards => #{@player.show_hand}"
    puts "_____________________________"
    puts ""
    puts "--------->>#{whose_turn}<<----------"
    puts "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
    puts ""
  end

  def dealers_handscore
    return @dealer.handscore(:player) if whose_turn == @player
    @dealer.handscore
  end

  def dealers_hand
    return [@dealer.show_hand[0]] if whose_turn == @player
    @dealer.show_hand 
  end

  def prepare
    new_round
    @player.roundscore = @dealer.roundscore = 0
    @deck.mix
  end

  def new_round
    @whose_turn = @player
    @player.handscore = @dealer.handscore = 0
    @dealer.hand, @player.hand = [], []
  end
end

class Deck
  attr_reader :cards
  
  def initialize
    mix
  end

  def mix
    @cards = []
    SUIT.each do |suit|
      CARDS.each{ |type,_| @cards << Card.new(suit, type)}
    end
    @cards.shuffle! 
  end   

  def to_s
    @cards
  end
end
#------------------------------------
class Card
  attr_reader :suit, :type

  def initialize(suit, type)
    @suit = suit
    @type = type
  end
end
#------------------------------------
class Participant
  attr_accessor :hand, :move, :handscore, :roundscore
  
  def initialize
    @hand = []
    @move = nil
    @handscore = @roundscore = 0
  end


  def handscore(whose_turn = :dealer)
    return CARDS[hand.first.type] if whose_turn == :player
    @handscore = 0
    @hand.each{ |card| @handscore += CARDS[card.type]} 
    if busted? && include_spezialcard?
      @handscore -= 10
    end
    @handscore
  end

  def include_spezialcard?
    @hand.any?{ |card| card.type == SPECIALCARD}
  end

  def show_hand
    @hand.map{ |card| "|#{card.suit} #{card.type}|" }
  end

  def busted?
    @handscore > MAX
  end
end
#------------------------------------
class Player < Participant
  def to_s
    'Player'
  end 
end
#------------------------------------
class Dealer < Participant  
  def to_s
    'Dealer'
  end 

  def over_min?
    @handscore >= DEALER_MIN
  end
end

Game.new.play

