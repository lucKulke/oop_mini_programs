class History
  attr_accessor :moves
  def initialize
    @moves = []
  end

  def display
    puts "History : #{moves}" 
  end

  def reset
    @moves = []
  end
end