require 'pixel'

class Enemy < Pixel
  def control_cost; 5; end
  def max_health; 400; end
  def kill_score; 600; end
  def damage; 10; end
  def force; 1.2; end
  def num_kills; 1; end
  def initial_color; Color::RED; end

  def controlled?; not @controller.nil?; end

  def initialize(space, options = {})
    super(space, options)

    @hurt = Sample["hurt_controlled.wav"]
    uncontrol
  end

  def control(controller)
    @controller = controller
    color.red = color.blue = color.green = 0
  end

  def uncontrol
    @controller = nil
    color.red = initial_color.red
    color.green = initial_color.green
    color.blue = initial_color.blue
  end

  def die
    if player = Player.all.first
      player.lose_control if controlled?
      $window.score += kill_score
      $window.current_game_state.add_kills num_kills
    end

    super
  end

  def hurts?(enemy)
    super or ((enemy.class == self.class) and (controlled? or enemy.controlled?))
  end

  def health=(value)
    old = health
    super(value)
    $window.score += old - health if old > health
  end

  def update
    super

    if controlled?
      color.blue = (((@controller.energy * 155.0) / @controller.max_energy) + 100).to_i
      color.red = [initial_color.red - color.blue, 0].max
      color.green = [initial_color.green - color.blue, 0].max
    else
      # Don't move if wounded.
      if health >= last_health and player = Player.all.first
        angle = Gosu::angle(x, y, player.x, player.y)
        distance = distance_to(player)
        x_offset = offset_x(angle, distance)
        y_offset = offset_y(angle, distance)

        # Home in on the player's location.
        move(x_offset / distance, y_offset / distance)
      end
    end
  end
end
