module EasyGeometry
  module D2
    # A vector in a 2-dimensional Euclidean space.
    class Vector
      attr_reader :x, :y

      EQUITY_TOLERANCE = 0.0000000000001
      
      def initialize(x, y)
        @x = x; @y = y

        validate!
        converting_to_rational!
      end

      # Compare self and other Vector.
      def ==(other)
        return false unless other.is_a?(Vector)
        (x - other.x).abs < EQUITY_TOLERANCE && (y - other.y).abs < EQUITY_TOLERANCE
      end

      # Subtract two vectors.
      def -(other)
        raise TypeError, "Subtract between Vector and #{ other.class } is not defined" unless other.is_a?(Vector)
        Vector.new(self.x - other.x, self.y - other.y)
      end

      # Returns a non-zero vector that is orthogonal to the
      # line containing `self` and the origin.
      def orthogonal_direction
        # if a coordinate is zero, we can put a 1 there and zeros elsewhere
        return Vector.new(1, 0) if x.zero?
        return Vector.new(0, 1) if y.zero?

        # if the first two coordinates aren't zero, we can create a non-zero
        # orthogonal vector by swapping them, negating one, and padding with zeros
        Vector.new(-y, x)
      end

      # It is positive if other vector should be turned counter-clockwise in order to superpose them.
      # It is negetive if other vector should be turned clockwise in order to superpose them.
      # It is zero when vectors are collinear.
      def cross_product(other)
        raise TypeError, "Cross product between Vector and #{ other.class } is not defined" unless other.is_a?(Vector)
        x * other.y - y * other.x
      end

      # Dot product, also known as inner product or scalar product.
      def dot(other)
        raise TypeError, "Scalar (dot) product between Vector and #{ other.class } is not defined" unless other.is_a?(Vector)
        x * other.x + y * other.y
      end

      # Converts the vector to a point
      def to_point
        Point.new(x, y)
      end

      private

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
