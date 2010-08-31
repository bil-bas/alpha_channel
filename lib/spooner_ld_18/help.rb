class Help < GameStates::Popup
  def initialize(options = {})
    text =<<END_TEXT

    <b><c=88bb88>=== #{Game::NAME} (Spooner's LD-18 game: "Enemies as weapons") ===</c></b>

    It is hell being a pixel. Why can't they all just get along?


    <b><c=88bb88>= How to play =</c></b>

      * <c=ff0000>Red</c> is evil; <c=ff0000>Red</c> wants to hurt <c=4444ff>Blue</c>!
        <c=ffff00>Yellow</c> is <i>so</i> nasty, it makes <c=ff0000>Red</c> look nice by comparison!
        Thankfully, <c=00ff00>Green</c> is too busy thinking to even notice <c=4444ff>Blue</c>.

      * Take control of other pixels, and use them to protect yourself!

      * Controlling is very strenuous and will use up your limited
        energy reserves (<c=4444ff>Blueness</c>).

      * Pixels hurt pixels that aren't the same colour.
        It has always been like that, but no-one knows exactly why...
        <c=ffff00>Yellow</c> is so dangerous, that even <c=ff0000>Red</c> avoids it, but <c=00ff00>Green</c> is more
        interested in musing on the nature of the Great Electron Gun. 


    <b><c=88bb88>= Controls =</c></b>

      * ARROW KEYS OR WASD: Move self (or a controlled Pixel).

      * SPACE OR RETURN: Take/relinquish control of a another Pixel.

      * P: Pause

      * CONTROL+Q: Exit game.

    <c=aaaaaa>(Escape to close this help)</c>
END_TEXT

    super options
    @text = Text.new(text, :x => 20, :y => 10, :align => :left, :zorder => Chingu::DEBUG_ZORDER + 1001, :size => 13)
  end
end