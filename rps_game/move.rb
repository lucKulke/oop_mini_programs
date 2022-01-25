require_relative "player.rb"
class Move
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    case @value
    when 'rock'
      other_move.scissors? ? true : false
    when 'paper'
      other_move.rock? ? true : false
    when 'scissors'
      other_move.paper? ? true : false
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
end