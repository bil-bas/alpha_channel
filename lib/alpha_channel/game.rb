Config = RbConfig if RUBY_VERSION > '1.9.2'

require 'chingu'
require 'chipmunk'
require_relative 'chipmunk_ext/space'
require 'texplay'
TexPlay.set_options :caching => false#
require 'fidgit'
require_relative 'fidgit_ext/cursor'

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
require 'fileutils'

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
require_relative 'states/high_scores'
require_relative 'states/level'
require_relative 'states/menu'
require_relative 'states/enter_name'
require_relative 'objects/pixel_fragment'
require_relative 'objects/player'

module ZOrder
  BACKGROUND, LABEL, LIVES, SCAN_LINES, CONTROL, PIXEL, PARTICLES, OVERLAY = *(0..100)
  GUI = Float::INFINITY
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

SETTINGS_FOLDER = File.expand_path("~/.alpha_channel_spooner")
SETTINGS_FILE = File.join(SETTINGS_FOLDER, "settings.yml")
FileUtils.mkdir_p SETTINGS_FOLDER

DEFAULT_SETTINGS = {
    difficulty: :normal,
    music_volume: 0.25,
    music_muted: false
}

class Game < Window
  NAME = "Alpha Channel"
  INITIAL_LIVES = 3
  
  attr_reader :pixel, :frame_time, :score
  attr_accessor :lives, :level

  NUM_SCORES = 20

  HIGH_SCORE_LOGIN = "alpha_channel_00"
  HIGH_SCORE_PASSWORD = "cazoo_of_solid_gold"
  DIFFICULTIES = {easy: 27, normal: 28, hard: 29}

  def initialize(full_screen)
    enable_undocumented_retrofication

    @settings = YAML::load_file(SETTINGS_FILE) rescue {}
    @settings = DEFAULT_SETTINGS.merge @settings

    save_settings

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

    @exception = nil
  end

  def difficulty; @settings[:difficulty]; end
  def difficulty=(difficulty)
    @settings[:difficulty] = difficulty
    save_settings
    difficulty
  end

  def save_settings
    File.open(SETTINGS_FILE, "w") {|f| f.write @settings.to_yaml } rescue nil
  end

  def difficulties
    DIFFICULTIES.keys
  end

  def score=(score); @score = score.to_i; end

  def offline_high_score?
    score > (@offline_high_scores[difficulty][NUM_SCORES - 1] || 0)
  end

  def online_high_score?
    score > (@online_high_scores[difficulty][NUM_SCORES - 1] || 0)
  end

  def high_score?
    online_high_score? or offline_high_score?
  end

  def offline_high_scores(difficulty)
    @offline_high_scores[difficulty]
  end

  def online_high_scores(difficulty)
    @online_high_scores[difficulty]
  end

  def offline_high_score
    score = @offline_high_scores[difficulty][0]
    score.is_a?(Hash) ? score[:score] : 0
  end

  def online_high_score
    score = @online_high_scores[difficulty][0]
    score.is_a?(Hash) ? score[:score] : 0
  end

  def high_score
    [online_high_score, offline_high_score].max
  end

  def add_high_score(name)
    puts "Recording high score: #{name}:#{score} on #{difficulty}"

    @offline_high_scores[difficulty].add name: name, score: score, text: "level:#{@level}"
    begin
      @online_high_scores[difficulty].add name: name, score: score, text: "level:#{@level}"
      @online_high_scores[difficulty].load
    rescue
      # Offline - don't worry about it.
    end
  end

  def close
    Kernel.exit # Kernel.exit! segfaults, as does letting the window close normally.
  end

  def alter_volume(amount)
    if @music.playing?
      @music.volume += amount
      @settings[:music_volume] = @music.volume
      save_settings
    end
  end

  def toggle_music
    if @music.playing?
      @music.pause
      @settings[:music_muted] = true
      save_settings
    else
      @music.play true
      @settings[:music_muted] = false
      save_settings
    end
  end

  def setup
    @lives = 0
    @score = 0

    @online_high_scores = Hash.new do |scores, difficulty|
      scores[difficulty] = Chingu::OnlineHighScoreList.new limit: NUM_SCORES, login: HIGH_SCORE_LOGIN,
                                                           password: HIGH_SCORE_PASSWORD, game_id: DIFFICULTIES[difficulty]
      scores[difficulty].load
    end

    @offline_high_scores = Hash.new do |scores, difficulty|
      scores[difficulty] = Chingu::HighScoreList.new size: NUM_SCORES, file: File.join(SETTINGS_FOLDER, "scores_#{difficulty}.yml")
      scores[difficulty].load
    end

    @music = Song["Alpha_Alarm.ogg"]
    @music.volume = @settings[:music_volume]
    toggle_music unless @settings[:music_muted]

    push_game_state Menu
  end

  def draw
    draw_started = milliseconds

    super
    @used_time += milliseconds - draw_started
  rescue => ex
    @exception = ex
  end

  def update
    if @exception
      puts "#{@exception.class}: #{@exception.message}\n#{@exception.backtrace.join("\n")}"
      raise @exception
    end

    update_started = milliseconds

    now = Time.now.to_f
    @frame_time = [now - @previous_time, 0.1].min

    super
    music = @music.playing? ? "#{(@music.volume * 100).round}%" : "off"
    self.caption = "#{NAME} v#{AlphaChannel::VERSION} - F1 or H for help [FPS: #{[@potential_fps, 999].min}] Music: #{music}"

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

  # Ensure that all Gosu call-backs catch errors properly.
  %w(needs_redraw? needs_cursor? lose_focus button_down button_up).each do |callback|
    define_method callback do |*args|
      begin
        super(*args)
      rescue => ex
        @exception = ex
      end
    end
  end

  def self.run
    new(false).show
  end
end

