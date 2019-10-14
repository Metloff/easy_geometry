module Geometry
  module D2
    # An infinite line in 2-dimensional Euclidean space.
    class Line < LinearEntity

      # 
      # Parameters:
      #   GeometryEntity
      # 
      # Returns:
      #   true if `other` is on this Line.
      #   false otherwise.
      # 
      def contains?(other)
        if other.is_a?(Point)
          return Point.is_collinear?(other, self.p1, self.p2)    
        end

        if other.is_a?(LinearEntity)
          return Point.is_collinear?(other.p1, other.p2, self.p1, self.p2)
        end

        return false
      end

      # Finds the shortest distance between a line and a point.
      # 
      # Raises
      #   ======
      #   TypeError is raised if `other` is not a Point
      def distance(other)
        other = Point.new(other[0], other[1]) if other.is_a?(Array)
        raise TypeError, "Distance between Line and #{ other.class } is not defined" unless other.is_a?(Point)

        return 0 if self.contains?(other)
        self.perpendicular_segment(other).length
      end

      # Returns True if self and other are the same mathematical entities
      def ==(other)
        return false unless other.is_a?(Line)

        Point.is_collinear?(self.p1, other.p1, self.p2, other.p2)
      end

      # The equation of the line: ax + by + c.
      def equation
        if p1.x == p2.x
          return "x - #{p1.x}"
        elsif p1.y == p2.y
          return "#{p2.y} - p1.y"
        end

        "#{a}*x + #{b}*y + #{c} = 0"
      end

      # The coefficients 'a' for ax + by + c = 0.
      def a
        @a ||= self.p1.y - self.p2.y
      end

      # The coefficients 'b' for ax + by + c = 0.
      def b
        @b ||= self.p2.x - self.p1.x
      end

      # The coefficients 'c' for ax + by + c = 0.
      def c
        @c ||= self.p1.x * self.p2.y - self.p1.y * self.p2.x
      end
    end
  end
end
