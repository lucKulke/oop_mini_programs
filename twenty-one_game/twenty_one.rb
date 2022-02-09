require 'yaml'
MESSAGE = YAML.load_file('messages.yml')
CARDS = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 11 }.freeze
SUIT = ["\u2663", "\u2666", "\u2665", "\u2660"]
MAX = 21
DEALER_MIN = 17

module Displayable

  def promt(message)
    puts message
  end

  def clear_terminal
    system 'clear'
  end

end

class Game
  include Displayable

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @game_table = GameTable.new(@player, @dealer)
  end

  def play
    display_message('welcome')
    display_table
    loop do 
      prepares_table
      loop do  
        deal_cards
        display_table
        
        participants_turn
        
        display_winner
        
        break unless decision_about('round')
      end
      break unless decision_about('game')
    end
    display_message('goodbye')
  end


  def display_winner
    display_message(determine_winner)
  end

  def determine_winner
    if deck_empty?
      'nobody_won'
    elsif @dealer.busted? || @dealer.handscore < @player.handscore
      'player_won'
    else
      'dealer_won'
    end
  end

  
  def participants_turn
    
    loop do 
      players_decision = decision_about('hit_or_stay', :turn) ? :hit : :stay 
      @player.hand << @game_table.deck.cards.shift if players_decision == :hit
      display_table
      break if some_one_busted? || players_decision == :stay || deck_empty?
    end
      
    display_message('dealers_turn')
    
    loop do 
      sleep(2)
      @player.hand << @game_table.deck.cards.shift
      display_table
      break if some_one_busted? || over_min? || deck_empty?
    end
    
  end

  def deck_empty?
    @game_table.deck.cards.size < 5
  end

  def some_one_busted?
    [@dealer.handscore, @player.handscore].any?{ |score| score > MAX }
  end

  def over_min?
    @dealer.handscore < DEALER_MIN
  end

  def decision_about(decision, aktion=:loop_break)
    aktion == :loop_break ? ask_for_decision("\n", 'n', decision) : ask_for_decision('h', 's', decision) 
  end

  def ask_for_decision(go, stop, decision)
    display_message(decision)
    decision = nil
    loop do 
      decision = gets.chomp.downcase[0]
      break if [go, stop].include?(decision)
      display_message('invalid_input')
    end
    decision == go
  end

  def deal_cards
    @game_table.new_round
    2.times do 
      [@player, @dealer].each{ |participant| participant.hand << @game_table.deck.cards.shift}
    end
  end

  def prepares_table
    @game_table.prepare
  end

  def display_table
    @game_table.display
  end

  def display_message(status)
    promt(MESSAGE[status])
  end

end

class GameTable
   attr_accessor :deck
  
  def initialize(player, dealer)
    @player = player
    @dealer = dealer
    @deck = Deck.new
  end

  def display
    puts "______Twenty-One_______"
    puts ""
    puts "Deck size = #{"deck.size"}"
    puts ""
    puts "      PlayerP. |  DealerP. "
    puts "-----------------------------"
    puts "total     #{@player.roundscore}          #{@dealer.roundscore}"
    puts "hand      #{@player.handscore}          #{@dealer.handscore}" 
    puts "_____________________________"
    puts ""
    puts "Dealer:"
    puts "cards => #{@dealer.show_hand}"
    puts ""
    puts "Player:"
    puts "cards => #{@player.show_hand}"
    puts "_____________________________"
    puts ""
    puts "------>>#{"whose_turn_is"}<<-------"
    puts "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
    puts ""
  end

  def prepare
    new_round
    @player.roundscore = @dealer.roundscore = 0
    @deck.mix
  end

  def new_round
    @player.handscore = @dealer.handscore = 0
    @dealer.hand, @player.hand = [], []
  end

end

class Deck
  attr_reader :cards
  
  def initialize
    @cards = []
    mix
  end

  def mix
    SUIT.each do |suit|
      CARDS.each{ |type,_| @cards << Card.new(suit, type)}
    end
    @cards.shuffle!      
  end   

end

class Card
  attr_reader :suit, :type

  def initialize(suit, type)
    @suit = suit
    @type = type
  end

end

class Participant
  attr_accessor :hand, :move, :handscore, :roundscore
  
  def initialize
    @hand = []
    @move = nil
    @handscore = @roundscore = 0
  end

  def update_handscore
    @handscore = 0
    @hand.each{ |card| @handscore += CARDS[card.type]} 
  end

  def show_hand
    update_handscore
    @hand.map{ |card| "|#{card.suit} #{card.type}|" }
  end

  def busted?
    handscore > MAX
  end

end


class Player < Participant
end

class Dealer < Participant
end

deck = Deck.new

Game.new.play

