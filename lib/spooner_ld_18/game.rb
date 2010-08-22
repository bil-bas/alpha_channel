require 'rubygems' rescue nil

require 'chingu'

require 'yaml' # required for ocra.

include Gosu
include Chingu

require 'level_transition'
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

BIN_DIR = File.join(INSTALL_DIR, 'bin')
ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

FONT = File.join(INSTALL_DIR, 'media', 'SWFIT_SL.TTF')

class Game < Window
  NAME = "Alpha Channel"
  attr_reader :particles, :high_score
  attr_accessor :score

  HIGH_SCORE_FILE = File.join(INSTALL_DIR, 'high_score.dat')

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

    @particles = []

    Sample["level.wav"].play

    @score = 0
    @high_score = File.open(HIGH_SCORE_FILE, "r") { |file| file.readline.to_i } rescue 0
    
    push_game_state(LevelTransition.new(1))
  end

  def game_over
    if @score > @high_score
      @high_score = @score
      File.open(HIGH_SCORE_FILE, "w") { |file| file.puts @high_score } rescue nil
      true
    else
      false
    end  
  end

  def random_position(extra_objects = [])
    min_distance = {Player => 30, DeadPixel => 25, Enemy => 20}
    all = Player.all + Enemy.all + DeadPixel.all + extra_objects
    loop do
      pos = [rand(($window.width / $window.factor) - 16) + 8, rand(($window.height / $window.factor) - 16) + 8]
      too_close = false
      all.each do |other|
        if distance(pos[0], pos[1], other.x, other.y) < min_distance[other.class]
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

  def add_particle(particle)
    @particles << particle
  end

  def remove_particle(particle)
    @particles.delete particle
  end
end

exit if defined? Ocra

Game.new.show