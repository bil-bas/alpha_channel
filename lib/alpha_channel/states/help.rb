require_relative "overlay"

class Help < Overlay
  def initialize(inputs)
    super inputs

    @@text ||= File.read File.expand_path "help.txt", File.dirname(__FILE__)

    @text = Text.new(@@text, x: 20, y: 20, align: :left, size: 13)
  end

  def draw
    super
    @text.draw
  end
end