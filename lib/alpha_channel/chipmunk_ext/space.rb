module CP
  class Space
    # Collision between a and b.
    def on_collision(a, b)
      raise "requires block" unless block_given?

      Array(a).each do |c|
        Array(b).each do |d|
          add_collision_handler(c, d) do |x, y|
            # Prevent collisions between objects that have already been destroyed.
            if x.object and y.object
              yield x.object, y.object
            else
              false
            end
          end
        end
      end
    end
  end
end