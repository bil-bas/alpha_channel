class Help < GameStates::Popup
  def initialize(options = {})
    text =<<END_TEXT

    === PIXHELL (Spooner's LD-18 game: "Enemies as weapons") ===

    It is hell being a pixel. Why can't they all just get along?


    = How to play =

      * Red is evil; Red wants to hurt you!

      * Take control of Red, when it comes near, and use it to protect yourself from the other Reds!

      * Controlling Red is strenuous and will use up your limited energy reserves (Blueness).

      * All colours hurt colours that aren't the same. Green isn't too painful, though :)


    = Controls =

      * Arrow keys or WASD: Move self (or a controlled Red).

      * Space or Return: Take/relinquish control of Red.

      * P: Pause

      * Control+Q: Exit game.


    (Escape to close this help)
END_TEXT

    options = { :text => text }.merge! options
    super options
  end
end