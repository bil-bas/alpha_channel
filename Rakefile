Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'

require_relative "lib/alpha_channel/version"
APP = "alpha_channel"
APP_READABLE = "Alpha Channel"
RELEASE_VERSION = AlphaChannel::VERSION

LICENSE_FILE = "COPYING.txt"

# My scripts which help me package games.
require_relative "../release_packager/lib/release_packager"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

PIXEL_GLOW_IMAGE = "media/image/pixel_glow.png"
BEAM_IMAGE = "media/image/control_beam.png"
FRAGMENT_GLOW_IMAGE = "media/image/fragment_glow.png"

desc "Generate images"
task "generate:images" do
  require 'gosu'
  require 'texplay'
  $window = Gosu::Window.new 10, 10, false

  create_pixel_glow
  create_control_beam
  create_fragment_glow
end

def create_pixel_glow
  t = Time.new.to_f

  glow = TexPlay.create_image($window, 160, 160, color: :alpha)
  glow.refresh_cache

  center = glow.width / 2
  radius =  glow.width / 2
  pixel_width = 16 # Radius of the pixel.
  pixel_radius = radius - pixel_width # Radius of the glow outside the pixel itself.

  glow.circle center, center, radius, color: :white, filled: true,
              color_control: lambda {|source, dest, x, y|
                # Glow starts at the edge of the pixel (well, its radius, since glow is circular, not rectangular)
                distance = Gosu::distance(center, center, x, y) - pixel_width
                dest[3] = (1 - (distance / pixel_radius)) ** 2
                dest
              }

  glow.save PIXEL_GLOW_IMAGE

  puts "Created #{PIXEL_GLOW_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"
end

def create_fragment_glow
  t = Time.new.to_f

  glow = TexPlay.create_image($window, 80, 80, color: :alpha)
  glow.refresh_cache

  center = radius = glow.width / 2

  glow.circle center, center, radius, color: :white, filled: true,
                color_control: lambda {|source, dest, x, y|
                  distance = Gosu::distance(center, center, x, y)
                  dest[3] = ((1 - (distance / radius)) ** 2) / 8.0
                  dest
                }

  glow.save FRAGMENT_GLOW_IMAGE

  puts "Created #{FRAGMENT_GLOW_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"
end

def create_control_beam
  t = Time.new.to_f

  image = TexPlay.create_image($window, 32, 32, color: :alpha)
  image.refresh_cache

  center = image.width / 2
  radius =  image.width / 2

  image.circle center, center, radius, color: :white, filled: true,
               color_control: lambda {|source, dest, x, y|
                 distance = Gosu::distance(center, center, x, y)
                 dest[3] = ((1 - (distance / radius)) ** 2) / 2
                 dest
               }

  image.save BEAM_IMAGE

  puts "Created #{BEAM_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"
end





