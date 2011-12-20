Config = RbConfig if RUBY_VERSION > '1.9.2'

require 'chingu'
require 'chipmunk'
require_relative 'chipmunk_ext/space'
require 'texplay'
TexPlay.set_options :caching => false

begin
  require 'bundler/setup' unless defined?(OSX_EXECUTABLE) or ENV['OCRA_EXECUTABLE']

rescue LoadError => ex
  $stderr.puts ex
  $stderr.puts "Bundler gem not installed. To install:\n  gem install bundler"
  exit 0
rescue Exception
  $stderr.puts "Gem dependencies not met. To install:\n  bundle install"
  exit 0
end

begin
  require 'pry-remote' if DEVELOPMENT_MODE
rescue LoadError
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
require_relative 'states/menu'
require_relative 'objects/pixel_fragment'
require_relative 'objects/player'

module ZOrder
  BACKGROUND, LABEL, LIVES, SCAN_LINES, CONTROL, PIXEL, PARTICLES, OVERLAY = (0..100).to_a
end

media_dir =  File.join(EXTRACT_PATH, 'media')
Image.autoload_dirs << File.join(media_dir, 'image')
Sample.autoload_dirs << File.join(media_dir, 'sound')
Song.autoload_dirs << File.join(media_dir, 'music')

BIN_DIR = File.join(EXTRACT_PATH, 'bin')
ENV['PATH'] = "#{BIN_DIR};#{ENV['PATH']}"

FONT = File.join(EXTRACT_PATH, 'media/font/pixelated.ttf')
Text.font = FONT

KEYS = YAML::load_file File.expand_path "keys.yml", File.dirname(__FILE__)

class Game < Window
  NAME = "Alpha Channel"
  INITIAL_LIVES = 3
  
  attr_reader :high_score, :pixel, :frame_time
  attr_accessor :score, :lives

  HIGH_SCORE_FILE = File.join(ROOT_PATH, 'alpha_channel_high_score.dat')

  def initialize(full_screen)
    enable_undocumented_retrofication

    super(640, 480, full_screen)

    if DEVELOPMENT_MODE
      Thread.fork { binding.remote_pry }
      on_input(:"f12") { binding.pry }
    end

    @pixel = TexPlay.create_image(self, 1, 1)
    @pixel.refresh_cache
    @pixel.clear color: :white

    on_input(:q) { close if holding_any? :left_control, :right_control }
    on_input(:"holding_+") { alter_volume(+0.01)  }
    on_input(:"holding_-") { alter_volume(-0.01) }
    on_input(:m) { toggle_music }

    @previous_time = Time.now.to_f
    @frame_time = 0

    @used_time = 0
    @last_time_fps_calculated = milliseconds
    @potential_fps = 0
  end

  def close
    Kernel.exit # Kernel.exit! segfaults, as does letting the window close normally.
  end

  def alter_volume(amount)
    @music.volume += amount if @music.playing?
  end

  def toggle_music
    if @music.playing?
      @music.pause
    else
      @music.play true
    end
  end

  def setup
    @lives = 0
    @score = 0
    @high_score = File.open(HIGH_SCORE_FILE, "r") { |file| file.readline.to_i } rescue 0

    @music = Song["Alpha_Alarm.ogg"]
    @music.volume = 0.25
    toggle_music

    push_game_state Menu
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

  def draw
    draw_started = milliseconds

    super
    @used_time += milliseconds - draw_started
  end

  def update
    update_started = milliseconds

    now = Time.now.to_f
    @frame_time = [now - @previous_time, 0.1].min

    super
    music = @music.playing? ? "#{(@music.volume * 100).round}%" : "off"
    self.caption = "#{NAME} v#{AlphaChannel::VERSION} - F1 or H for help [FPS: #{fps.to_s.rjust(2)} (#{@potential_fps})] Music: #{music}"

    @previous_time = now

    @used_time += milliseconds - update_started

    recalculate_cpu_load
  end

  def recalculate_cpu_load
    if (milliseconds - @last_time_fps_calculated) >= 1000
      @potential_fps = (fps / [(@used_time.to_f / (milliseconds - @last_time_fps_calculated)), 0.0001].max).floor
      @used_time = 0
      @last_time_fps_calculated = milliseconds
    end
  end

  def self.run
    new(false).show
  end
end

