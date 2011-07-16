require_relative 'boss'

class ShooterPixel < Boss
  SHOOT_RANGE = 125
  PUSH_RANGE = 75
  INITIAL_COLOR = Color.new(255, 255, 0, 255)
  SHOOT_FORCE = 100
  PUSH_FORCE = 1
  MIN_SHOOT_DELAY = 2000

  def force; 1.2; end
  def damage; 5; end
  def initial_color; INITIAL_COLOR; end
  def intensity; 0.5; end

  def boss_update
    return unless player = parent.player

    nearest_distance = Float::INFINITY
    if player
      @last_shot_at ||= $window.ms
      if @shootee.nil? and (not controlled?) and ($window.ms - @last_shot_at > MIN_SHOOT_DELAY)
        @shootee = nil
        # Find which one to shoot.
        (Enemy.all - [self]).each do |pixel|
          distance = distance_to(pixel)
          if not pixel.controlled? and distance < SHOOT_RANGE and pixel.distance_to(player) < distance
            if distance < nearest_distance
              @shootee = pixel
              nearest_distance = distance
            end
          end
        end

        # Shoot the chosen idiot :)
        if @shootee
          @shootee.push(player.x, player.y, SHOOT_FORCE)
          @last_shot_at = $window.ms
        end
      end
      
      # Push those really close away.
      (Enemy.all - [self, @shootee]).each do |pixel|
        pixel.push(x, y, -PUSH_FORCE) if distance_to(pixel) < PUSH_RANGE and not pixel.controlled?
      end
    end
  end

  def draw
    super

    if @shootee    
      @@glow.draw(@shootee.x - @@glow.width / 2, @shootee.y - @@glow.height / 2, zorder + 1, 1, 1, glow_color, :additive)
      @shootee = nil if @shootee.shape.body.vel.x.abs < 200 and @shootee.shape.body.vel.y.abs < 200
    end
  end
end