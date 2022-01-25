class Scoreboard
  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def display
    puts
    puts "#{@human.name} score is: #{@human.score}"
    puts '------------------'
    puts "#{@computer.name} score is: #{@computer.score}"
    puts
  end
end