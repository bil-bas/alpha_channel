Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'

require_relative "lib/alpha_channel/version"
APP = "alpha_channel"
APP_READABLE = "Alpha Channel"
RELEASE_VERSION = AlphaChannel::VERSION

OSX_GEMS = %w[chingu] # Source gems for inclusion in the .app package.

LICENSE_FILE = "COPYING.txt"

# My scripts which help me package games.
require_relative "../release_packager/lib/release_packager"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end





