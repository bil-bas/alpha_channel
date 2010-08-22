require 'pixel'

class Enemy < Pixel
  INITIAL_HEALTH = 400
  KILL_SCORE = 600
  TOTAL_SCORE = INITIAL_HEALTH + KILL_SCORE 

  def controlled?; not @controller.nil?; end

  def initialize(options = {})
    options = { :color => Color::RED.dup, :max_health => 400 }.merge! options
    super options

    @last_health = @max_health = @health = 400

    @speed = 0.3
    @damage = 10

    @hurt = Sample["hurt_controlled.wav"]
    uncontrol
  end

  def control(controller)
    @controller = controller
    color.red = 0
  end

  def uncontrol
    @controller = nil
    color.red = 255
    color.blue = 0
  end

  def die
    if player = Player.all.first
      player.lose_control if controlled?
      $window.score += KILL_SCORE
      $window.current_game_state.add_kill
    end

    super
  end

  def hurts?(enemy)
    super or ((enemy.class == self.class) and (controlled? or enemy.controlled?))
  end

  def health=(value)
    old = health
    super(value)
    $window.score += old - health
  end

  def update
    super

    if controlled?
      color.blue = (((@controller.energy * 155.0) / @controller.max_energy) + 100).to_i
      color.red = 255 - color.blue
      # You now damage other enemies.
      each_collision(Enemy) do |me, enemy|
        if enemy != self
          self.health -= enemy.damage
          enemy.health -= damage
          @hurt.play
        end
      end
    else
      # Don't move if wounded.
      if health == last_health and player = Player.all.first
        angle = Gosu::angle(x, y, player.x, player.y)
        distance = distance_to(player)
        x_offset = offset_x(angle, distance)
        y_offset = offset_y(angle, distance)

        # Home in on the player's location.
        left(-x_offset / distance) if x_offset < 0
        right(x_offset / distance) if x_offset > 0
        up(-y_offset / distance) if y_offset < 0
        down(y_offset / distance) if y_offset > 0
     end
    end
  end
end
