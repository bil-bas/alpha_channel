class Wall < BasicGameObject
  ELASTICITY = FRICTION = 1.0
  attr_reader :shape, :side

  def damage; 30; end
  
  def initialize(space, x1, y1, x2, y2, side)
    super()
    
    body = CP::Body.new(Float::INFINITY, Float::INFINITY)
    
    @shape = CP::Shape::Segment.new(body, CP::Vec2.new(x1, y1), CP::Vec2.new(x2, y2), 0.0)
    @shape.e = ELASTICITY
    @shape.u = FRICTION
    @shape.body.p = CP::Vec2.new(0, 0)
    @shape.collision_type = :wall
    @side = side
    @shape.object = self

    space.add_shape @shape # Body not needed, since we don't want to be affected by gravity et al.
  end
end