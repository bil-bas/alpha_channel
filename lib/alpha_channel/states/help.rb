require_relative "overlay"

class Help < Overlay
  TEXT = File.read(File.expand_path("help.txt", File.dirname(__FILE__)))

  def initialize(inputs)
    super inputs

    @text = Text.new(TEXT, x: 15, y: 10, align: :left, size: 13, zorder: ZOrder::GUI)
  end

  def draw
    super
    @text.draw
  end
end