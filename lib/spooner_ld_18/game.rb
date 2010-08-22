require 'rubygems' rescue nil

require 'chingu'

require 'yaml' # required for ocra.

include Gosu
include Chingu

require 'dead_pixel'
require 'enemy'
require 'help'
require 'game_over'
require 'help'
require 'level'
require 'pixel_fragment'
require 'player'

module ZOrder
  BACKGROUND, LABEL, PIXEL, CONTROL, PARTICLES, OVERLAY = (0..100).to_a
end

INSTALL_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
media_dir =  File.join(INSTALL_DIR, 'media')
Image.autoload_dirs << File.join(media_dir)
Sample.autoload_dirs << File.join(media_dir)

ENV['PATH'] = "#{File.join(INSTALL_DIR, 'bin')};#{ENV['PATH']}"

class Game < Window
  NAME = "Alpha Channel"
  attr_accessor :score

  # Allow others to read my private method!
  def ms
    self.send(:milliseconds)
  end

  def initialize
    super(640, 480, false)

    on_input(:q) { close if holding_any? :left_control, :right_control }
  end

  def setup
    retrofy
    self.factor = 4 # So 160x120

    Sample["level.wav"].play

    @score = 0
    
    push_game_state(GameStates::FadeTo.new(Level.new(1), :speed => 2))
  end

  def random_position(extra_objects = [])
    min_distance = {Player => 30, DeadPixel => 25, Enemy => 20}
    all = Player.all + Enemy.all + DeadPixel.all + extra_objects
    loop do
      pos = [rand(($window.width / $window.factor) - 16) + 8, rand(($window.height / $window.factor) - 16) + 8]
      too_close = false
      all.each do |other|
        if distance(*pos, other.x, other.y) < min_distance[other.class]
          too_close = true
          break
        end
      end
      return pos unless too_close
    end
  end

  def update
    super
    self.caption = "#{NAME} (spooner.github.com LD 18 - 'Enemies as weapons') F1 for help [FPS: #{fps}]"
  end
end

exit if defined? Ocra

Game.new.show