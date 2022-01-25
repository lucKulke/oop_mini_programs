require_relative "player.rb"

class Move
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    case @value
    when 'rock'
      other_move.scissors? || other_move.lizard?
    when 'paper'
      other_move.rock? || other_move.spock?
    when 'scissors'
      other_move.paper? || other_move.lizard?
    when 'lizard'
      other_move.spock? || other_move.paper?
    when 'spock'
      other_move.rock? || other_move.scissors?
    end
  end

  def ==(other_move)
    @value == other_move.value
  end

  def scissors?
    @value == 'scissor'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end
end
