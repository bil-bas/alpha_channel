require 'rubygems' rescue nil

require 'chingu'
require 'texplay'

class Game < Chingu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Spooner LD 18 - Enemies as weapons"
  end
end

Game.new.show