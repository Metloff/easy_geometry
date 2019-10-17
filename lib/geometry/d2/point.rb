module Geometry
  module D2
    # A point in a 2-dimensional Euclidean space.
    class Point
      attr_reader :x, :y

      EQUITY_TOLERANCE = 0.0000000000001

      def initialize(x, y)
        @x = x; @y = y

        validate!
        converting_to_rational!
      end

      # Project the point 'a' onto the line between the origin
      # and point 'b' along the normal direction.
      #
      # Parameters:
      #   Point, Point
      # 
      # Returns:
      #   Point
      #
      def self.project(a, b)
        unless a.is_a?(Point) && b.is_a?(Point)
          raise TypeError, "Project between #{ a.class } and #{ b.class } is not defined"
        end
        raise ArgumentError, "Cannot project to the zero vector" if b.zero?
  
        b * a.dot(b) / b.dot(b)
      end

      # Returns:
      #   true if there exists a line that contains `points`,
      # or if no points are given.
      #   false otherwise.
      # 
      def self.is_collinear?(*points)
        # raise TypeError, 'Args should be a Points' unless points.detect { |p| !p.is_a?(Point) }.nil?
        Point.affine_rank(*points.uniq) <= 1
      end

      # The affine rank of a set of points is the dimension
      # of the smallest affine space containing all the points.
      # 
      # For example, if the points lie on a line (and are not all
      # the same) their affine rank is 1.  
      # If the points lie on a plane but not a line, their affine rank is 2.  
      # By convention, the empty set has affine rank -1.
      def self.affine_rank(*points)
        raise TypeError, 'Args should be a Points' unless points.detect { |p| !p.is_a?(Point) }.nil?
        return -1 if points.length == 0

        origin = points[0]
        points = points[1..-1].map {|p| p - origin}

        Matrix[*points.map {|p| [p.x, p.y]}].rank
      end

      # Dot product, also known as inner product or scalar product.
      def dot(other)
        raise TypeError, "Scalar (dot) product between Point and #{ other.class } is not defined" unless other.is_a?(Point)
        x * other.x + y * other.y
      end

      # True if every coordinate is zero, False if any coordinate is not zero.
      def zero?
        return true if x.zero? && y.zero? 
        return false
      end

      # Compare self and other Point.
      def ==(other)
        return false unless other.is_a?(Point)
        (x - other.x).abs < EQUITY_TOLERANCE && (y - other.y).abs < EQUITY_TOLERANCE
      end

      # Subtraction of two points.
      def -(other)
        raise TypeError, "Subtract between Point and #{ other.class } is not defined" unless other.is_a?(Point)
        Point.new(self.x - other.x, self.y - other.y)
      end

      # Addition of two points.
      def +(other)
        raise TypeError, "Addition between Point and #{ other.class } is not defined" unless other.is_a?(Point)
        Point.new(self.x + other.x, self.y + other.y)
      end

      # Multiplication of point and number.
      def *(scalar)
        raise TypeError, "Multiplication between Point and #{ scalar.class } is not defined" unless scalar.is_a?(Numeric)
        Point.new(x * scalar, y * scalar)
      end

      # Dividing of point and number.
      def /(scalar)
        raise TypeError, "Dividing between Point and #{ scalar.class } is not defined" unless scalar.is_a?(Numeric)
        Point.new(x / scalar, y / scalar)
      end

      def <=>(other)
        return self.y <=> other.y if self.x == other.x 
        self.x <=> other.x
      end

      # Returns the distance between this point and the origin.
      def abs
        self.distance(Point.new(0, 0))
      end

      # Distance between self and another geometry entity.
      #
      # Parameters:
      #   geometry_entity
      # 
      # Returns:
      #   int
      #
      def distance(other)
        if other.is_a?(Point)
          return distance_between_points(self, other)
        end
        
        if other.respond_to?(:distance)
          return other.distance(self)
        end
        
        raise TypeError, "Distance between Point and #{ other.class } is not defined"
      end

      # Intersection between point and another geometry entity.
      # 
      # Parameters:
      #   geometry_entity
      # 
      # Returns:
      #   Array of Points
      # 
      def intersection(other)
        if other.is_a?(Point)
          return points_intersection(self, other)
        end

        if other.respond_to?(:intersection)
          return other.intersection(self)
        end

        raise TypeError, "Intersection between Point and #{ other.class } is not defined"
      end

      # The midpoint between self and another point.
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   Point
      # 
      def midpoint(other)
        raise TypeError, "Midpoint between Point and #{ other.class } is not defined" unless other.is_a?(Point)

        Point.new(
          (self.x + other.x) / 2,
          (self.y + other.y) / 2
        )
      end

      private

      def points_intersection(p1, p2)
        return [p1] if p1 == p2
        return []
      end

      def distance_between_points(p1, p2)
        # AB = √(x2 - x1)**2 + (y2 - y1)**2
        Math.sqrt( (p2.x - p1.x)**2 + (p2.y - p1.y)**2 )
        # Math.hypot((p2.x - p1.x), (p2.y - p1.y))
      end

      def validate!
        raise TypeError, 'Coords should be numbers' if !x.is_a?(Numeric) || !y.is_a?(Numeric)
      end

      def converting_to_rational!
        @x = Rational(x.to_s) unless x.is_a?(Rational)
        @y = Rational(y.to_s) unless y.is_a?(Rational)
      end
    end
  end
end
