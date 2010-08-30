class Help < GameStates::Popup
  def initialize(options = {})
    text =<<END_TEXT

    === #{Game::NAME} (Spooner's LD-18 game: "Enemies as weapons") ===

    It is hell being a pixel. Why can't they all just get along?


    = How to play =

      * Red is evil; Red wants to hurt you! Yellow makes Red look nice.

        Thankfully, green is too busy thinking to notice Blue.

      * Take control of other pixels, and use them to protect yourself!

      * Controlling is very strenuous and will use up your

        limited energy reserves (Blueness).

      * All colours hurt colours that aren't the same.

        Yellow is so dangerous, that even Red avoids it, but Green is laid back.


    = Controls =

      * Arrow keys or WASD: Move self (or a controlled Pixel).

      * Space or Return: Take/relinquish control of a Pixel.

      * P: Pause

      * Control+Q: Exit game.

    (Escape to close this help)
END_TEXT

    super options
    @text = Text.new(text, :x => 20, :y => 10, :align => :left, :zorder => Chingu::DEBUG_ZORDER + 1001, :size => 13)
  end
end