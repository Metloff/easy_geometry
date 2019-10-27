module EasyGeometry
  module D2
    # A segment in a 2-dimensional Euclidean space.
    class Segment < LinearEntity

      # Is the other GeometryEntity contained within this Segment?
      # 
      # Parameters:
      #   GeometryEntity or Array of Numeric(coordinates)
      # 
      # Returns:
      #   true if `other` is in this Segment.
      #   false otherwise.
      # 
      def contains?(other)
        other = Point.new(other[0], other[1]) if other.is_a?(Array)

        if other.is_a?(Point)
          if Point.is_collinear?(other, self.p1, self.p2)
            # if it is collinear and is in the bounding box of the
            # segment then it must be on the segment
            vert = (1/self.slope).zero?
            
            if vert
              return (self.p1.y - other.y) * (self.p2.y - other.y) <= 0
            end
            
            return (self.p1.x - other.x) * (self.p2.x - other.x) <= 0
          end
        end

        if other.is_a?(Segment)
          return self.contains?(other.p1) && self.contains?(other.p2)
        end

        return false
      end

      # Returns True if self and other are the same mathematical entities.
      # 
      # Parameters:
      #   GeometryEntity
      # 
      def ==(other)
        return false unless other.is_a?(Segment)
        [p1, p2].sort_by {|p| [p.x, p.y]} == [other.p1, other.p2].sort_by {|p| [p.x, p.y]}
      end

      def <=>(other)
        return self.p2 <=> other.p2 if self.p1 == other.p1 
        self.p1 <=> other.p1
      end

      # Finds the shortest distance between a line segment and a point.
      # 
      # Parameters:
      #   Point or Array of Numeric(coordinates)
      # 
      # Returns:
      #   Number
      # 
      def distance(other)
        other = Point.new(other[0], other[1]) if other.is_a?(Array)
        raise TypeError, "Distance between Segment and #{ other.class } is not defined" unless other.is_a?(Point)

        vp1 = other - self.p1
        vp2 = other - self.p2

        dot_prod_sign_1 = self.direction.to_point.dot(vp1) >= 0
        dot_prod_sign_2 = self.direction.to_point.dot(vp2) <= 0

        if dot_prod_sign_1 && dot_prod_sign_2
          return Line.new(self.p1, self.p2).distance(other)
        end

        if dot_prod_sign_1 && !dot_prod_sign_2
          return vp2.abs
        end

        if !dot_prod_sign_1 && dot_prod_sign_2
          return vp1.abs
        end
      end

      # The length of the line segment.
      def length
        @length ||= p1.distance(p2)
      end

      # The midpoint of the line segment.
      def midpoint
        @midpoint ||= p1.midpoint(p2)
      end

      # The perpendicular bisector of this segment.
      # If no point is specified or the point specified is not on the
      # bisector then the bisector is returned as a Line. 
      # Otherwise a Segment is returned that joins the point specified and the
      # intersection of the bisector and the segment.
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   Line or Segment
      # 
      def perpendicular_bisector(point=nil)
        l = self.perpendicular_line(self.midpoint)
        
        if !point.nil?
          point = Point.new(point[0], point[1]) if point.is_a?(Array)        
          raise TypeError, "This method is not defined for #{ point.class }" unless point.is_a?(Point)
          return Segment.new(point, self.midpoint) if l.contains?(point)
        end

        return l
      end
    end
  end
end
