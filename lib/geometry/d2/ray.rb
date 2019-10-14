module Geometry
  module D2
    # A Ray is a semi-line in the space with a source point and a direction.
    class Ray < LinearEntity

      # Is other GeometryEntity contained in this Ray?
      # 
      # Parameters:
      #   GeometryEntity
      # 
      # Returns:
      #   true if `other` is on this Line.
      #   false otherwise.
      # 
      def contains?(other)
        other = Point.new(other[0], other[1]) if other.is_a?(Array)

        if other.is_a?(Point)
          if Point.is_collinear?(other, self.p1, self.p2)
            # if we're in the direction of the ray, our
            # direction vector dot the ray's direction vector
            # should be non-negative
            return (self.p2 - self.p1).dot(other - self.p1) >= 0
          end
        end

        if other.is_a?(Ray)
          if Point.is_collinear?(self.p1, self.p2, other.p1, other.p2)
            return (self.p2 - self.p1).dot(other.p2 - other.p1) > 0
          end
        end

        if other.is_a?(Segment)
          return true if self.contains?(other.p1) && self.contains?(other.p2)
        end

        return false
      end

      # Finds the shortest distance between the ray and a point.
      # 
      # Raises
      #   ======
      #   TypeError is raised if `other` is not a Point
      def distance(other)
        raise TypeError, "Distance between Ray and #{ other.class } is not defined" unless other.is_a?(Point)

        return 0 if self.contains?(other)

        proj = Line.new(self.p1, self.p2).projection_point(other)
        if self.contains?(proj)
          return (other - proj).abs
        end
          
        (other - self.source).abs
      end

      # Returns True if self and other are the same mathematical entities
      def ==(other)
        return false unless other.is_a?(Ray)
        self.source == other.source && self.contains?(other.p2)
      end

      # The point from which the ray emanates.
      def source
        self.p1
      end

      # The x direction of the ray.
      # 
      # Returns:
      #     Positive infinity if the ray points in the positive x direction,
      #     negative infinity if the ray points in the negative x direction,
      #     or 0 if the ray is vertical.
      def xdirection
        return @xdirection if defined?(@xdirection)

        if self.p1.x < self.p2.x
          @xdirection = BigDecimal('Infinity')
        elsif self.p1.x == self.p2.x
          @xdirection = 0
        else
          @xdirection = -BigDecimal('Infinity')
        end

        @xdirection
      end

      # The y direction of the ray.
      # 
      # Returns:
      #     Positive infinity if the ray points in the positive y direction,
      #     negative infinity if the ray points in the negative y direction,
      #     or 0 if the ray is vertical.
      def ydirection
        return @ydirection if defined?(@ydirection)

        if self.p1.y < self.p2.y
          @ydirection = BigDecimal('Infinity')
        elsif self.p1.y == self.p2.y
          @ydirection = 0
        else
          @ydirection = -BigDecimal('Infinity')
        end

        @ydirection
      end

    end
  end
end
