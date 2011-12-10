Config = RbConfig if RUBY_VERSION > '1.9.2'

require 'chingu'
require 'chipmunk'
require 'texplay'
TexPlay.set_options :caching => false

begin
  require 'bundler/setup' unless defined?(OSX_EXECUTABLE) or ENV['OCRA_EXECUTABLE']

rescue LoadError
  $stderr.puts "Bundler gem not installed. To install:\n  gem install bundler"
  exit
rescue Exception
  $stderr.puts "Gem dependencies not met. To install:\n  bundle install"
  exit
end

require 'yaml' # required for ocra.

include Gosu
include Chingu

require_relative 'font'
require_relative 'version'
require_relative 'states/level_transition'
require_relative 'objects/dead_pixel'
require_relative 'objects/enemy'
require_relative 'states/help'
require_relative 'states/game_over'
require_relative 'states/help'
require_relative 'states/level'
require_relative 'objects/pixel_fragment'
require_relative 'objects/player'

module ZOrder
  BACKGROUND, LABEL, LIVES, SCAN_LINES, CONTROL, PIXEL, PARTICLES, OVERLAY = (0..100).to_a
end

media_dir =  File.join(EXTRACT_PATH, 'media')
Image.autoload_dirs << File.join(media_dir, 'image')
Sample.autoload_dirs << File.join(media_dir, 'sound')

BIN_DIR = File.join(EXTRACT_PATH, 'bin')
ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

FONT = File.join(EXTRACT_PATH, 'media/font/pixelated.ttf')
Text.font = FONT

class Game < Window
  NAME = "Alpha Channel"
  INITIAL_LIVES = 3
  
  attr_reader :particles, :high_score
  attr_accessor :score, :lives

  HIGH_SCORE_FILE = File.join(ROOT_PATH, 'high_score.dat')

  # Allow others to read my private method!
  def ms
    self.send(:milliseconds)
  end

  def initialize(full_screen)
    super(640, 480, full_screen)

    on_input(:q) { close if holding_any? :left_control, :right_control }
  end

  def setup
    @particles = []
    @lives = 0
    @score = 0
    @high_score = File.open(HIGH_SCORE_FILE, "r") { |file| file.readline.to_i } rescue 0
    
    push_game_state(LevelTransition.new(Level::INITIAL_LEVEL))
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
    size = Pixel::SIZE
    all = Player.all + Enemy.all + DeadPixel.all + extra_objects
    loop do
      pos = [rand($window.width - size * 2) + size, rand($window.height - size * 2) + size]
      too_close = false
      all.each do |other|
        if distance(pos[0], pos[1], other.x, other.y) < other.safe_distance
          too_close = true
          break
        end
      end
      return pos unless too_close
    end
  end

  def update
    super
    self.caption = "#{NAME} v#{AlphaChannel::VERSION} - F1 for help [FPS: #{fps}]"
  end

  def add_particle(particle)
    @particles << particle
  end

  def remove_particle(particle)
    @particles.delete particle
  end

  def self.run
    new(false).show
  end
end

