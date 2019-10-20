module EasyGeometry
  module D2
    # A base class for all linear entities (Line, Ray and Segment)
    # in 2-dimensional Euclidean space.
    class LinearEntity
      attr_reader :p1, :p2

      # Examples:
      # LinearEntity.new(Point.new(0, 0), Point.new(1, 2))
      # LinearEntity.new([0, 0], [1, 2])
      def initialize(point1, point2)
        @p1 = point1; @p2 = point2
        
        check_input_points!
        validate!
      end

      # The direction vector of the LinearEntity.
      # Returns:
      #   Point; the ray from the origin to this point is the
      # direction of `self`.
      # 
      def direction
        @direction ||= Vector.new(p2.x - p1.x, p2.y - p1.y)
      end

      # Return the non-reflex angle formed by rays emanating from
      # the origin with directions the same as the direction vectors
      # of the linear entities.
      # 
      # From the dot product of vectors v1 and v2 it is known that:
      # 
      # ``dot(v1, v2) = |v1|*|v2|*cos(A)``
      # 
      # where A is the angle formed between the two vectors. We can
      # get the directional vectors of the two lines and readily
      # find the angle between the two using the above formula.
      # 
      # 
      # Parameters:
      #    LinearEntity
      # 
      # Returns:
      #   angle in radians
      # 
      def angle_between(other)
        raise TypeError, 'Must pass only LinearEntity objects.' unless other.is_a?(LinearEntity)
        
        v1 = self.direction
        v2 = other.direction

        # Convert numerator to BigDecimal for more precision.
        numerator   = BigDecimal(v1.dot(v2).to_f.to_s)
        denominator = v1.to_point.abs * v2.to_point.abs

        return Math.acos(numerator / denominator)
      end

      # Are two LinearEntity parallel?
      # 
      # Parameters:
      #   LinearEntity
      # 
      # Returns:
      #   true if self and other LinearEntity are parallel.
      #   false otherwise.
      # 
      def parallel_to?(other)
        raise TypeError, 'Must pass only LinearEntity objects.' unless other.is_a?(LinearEntity)
        self.direction.cross_product(other.direction) == 0
      end

      # Are two linear entities perpendicular?
      # 
      # Parameters:
      #   LinearEntity
      # 
      # Returns:
      #   true if self and other LinearEntity are perpendicular.
      #   false otherwise.
      # 
      def perpendicular_to?(other)
        raise TypeError, 'Must pass only LinearEntity objects.' unless other.is_a?(LinearEntity)
        self.direction.dot(other.direction) == 0
      end

      # Are two linear entities similar?
      # 
      # Return:
      #  true if self and other are contained in the same line.
      # 
      def similar_to?(other)
        raise TypeError, 'Must pass only LinearEntity objects.' unless other.is_a?(LinearEntity)
        
        l = Line.new(p1, p2)
        l.contains?(other)
      end

      # The intersection with another geometrical entity
      # 
      # Parameters:
      #   Point or LinearEntity
      # 
      # Returns:
      #   Array of geometrical entities
      # 
      def intersection(other)
        other = Point.new(other[0], other[1]) if other.is_a?(Array)

        # Other is a Point.
        if other.is_a?(Point)
          return [other] if self.contains?(other)
          return []
        end

        # Other is a LinearEntity
        if other.is_a?(LinearEntity)
          # break into cases based on whether
          # the lines are parallel, non-parallel intersecting, or skew
          rank = Point.affine_rank(self.p1, self.p2, other.p1, other.p2)
          if rank == 1
            # we're collinear
            return [other] if self.is_a?(Line)
            return [self]  if other.is_a?(Line)  
                
            if self.is_a?(Ray) && other.is_a?(Ray)
              return intersect_parallel_rays(self, other)
            end

            if self.is_a?(Ray) && other.is_a?(Segment)
              return intersect_parallel_ray_and_segment(self, other)
            end

            if self.is_a?(Segment) && other.is_a?(Ray)
              return intersect_parallel_ray_and_segment(other, self)
            end

            if self.is_a?(Segment) && other.is_a?(Segment)
              return intersect_parallel_segments(self, other)
            end

          elsif rank == 2
            # we're in the same plane
            l1 = Line.new(self.p1, self.p2)
            l2 = Line.new(other.p1, other.p2)

            # check to see if we're parallel. If we are, we can't
            # be intersecting, since the collinear case was already
            # handled
            return [] if l1.parallel_to?(l2)
           
            # Use Cramers rule:
            # https://en.wikipedia.org/wiki/Cramer%27s_rule
            det = l1.a * l2.b - l2.a * l1.b
            det = det
            x = (l1.b * l2.c - l1.c * l2.b) / det
            y = (l2.a * l1.c - l2.c * l1.a ) / det

            intersection_point = Point.new(x, y)

            # if we're both lines, we can skip a containment check
            return [intersection_point] if self.is_a?(Line) && other.is_a?(Line)
                
            if self.contains?(intersection_point) && other.contains?(intersection_point)
              return [intersection_point] 
            end
                    
            return []
          else
            # we're skew
            return []
          end
        end

        if other.respond_to?(:intersection)
          return other.intersection(self)
        end

        raise TypeError, "Intersection between LinearEntity and #{ other.class } is not defined"
      end

      # Create a new Line parallel to this linear entity which passes
      # through the point `p`
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   Line
      # 
      def parallel_line(point)
        raise TypeError, 'Must pass only Point.' unless point.is_a?(Point)
        Line.new(point, point + self.direction.to_point)
      end

      # Create a new Line perpendicular to this linear entity which passes
      # through the point `point`.
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   Line
      # 
      def perpendicular_line(point)
        raise TypeError, 'Must pass only Point.' unless point.is_a?(Point)

        # any two lines in R^2 intersect, so blindly making
        # a line through p in an orthogonal direction will work
        Line.new(point, point + self.direction.orthogonal_direction.to_point)
      end

      # Create a perpendicular line segment from `point` to this line.
      # The enpoints of the segment are `point` and the closest point in
      # the line containing self. (If self is not a line, the point might
      # not be in self.)
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   Segment or Point (if `point` is on this linear entity.)
      # 
      def perpendicular_segment(point)
        raise TypeError, 'Must pass only Point.' unless point.is_a?(Point)

        return point if self.contains?(point)
            
        l = self.perpendicular_line(point)
        p = Line.new(self.p1, self.p2).intersection(l).first

        Segment.new(point, p)
      end

      # The slope of this linear entity, or infinity if vertical.
      # 
      # Returns:
      #   number or BigDecimal('Infinity')
      # 
      def slope
        return @slope if defined?(@slope)

        dx = p1.x - p2.x
        dy = p1.y - p2.y
  
        if dy == 0 
          @slope = 0.0 
        elsif dx == 0
          @slope = BigDecimal('Infinity')
        else
          @slope = dy / dx
        end

        @slope
      end

      # Test whether the point `other` lies in the positive span of `self`.
      # A point x is 'in front' of a point y if x.dot(y) >= 0.
      # 
      # Return
      #   -1 if `other` is behind `self.p1`, 
      #   0 if `other` is `self.p1` 
      #   1 if `other` is in front of `self.p1`.
      # 
      def span_test(other)
        raise TypeError, 'Must pass only Point.' unless other.is_a?(Point)
        return 0 if self.p1 == other

        rel_pos = other - self.p1
        return 1 if self.direction.to_point.dot(rel_pos) > 0
        
        return -1
      end

      # Project a point onto this linear entity.
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   Point
      # 
      def projection_point(p)
        Point.project(p - p1, self.direction.to_point) + p1
      end

      private

      def intersect_parallel_rays(ray1, ray2)
        if ray1.direction.dot(ray2.direction) > 0
          # rays point in the same direction
          # so return the one that is "in front"
          return [ray2]  if ray1.span_test(ray2.p1) >= 0
          return [ray1]
        end
            
        # rays point in opposite directions
        st = ray1.span_test(ray2.p1)        
        return []         if st < 0
        return [ray2.p1]  if st == 0

        [Segment.new(ray1.p1, ray2.p1)]
      end

      def intersect_parallel_ray_and_segment(ray, seg)
        st1 = ray.span_test(seg.p1) 
        st2 = ray.span_test(seg.p2)

        if st1 < 0 && st2 < 0
          return []
        elsif st1 >= 0 && st2 >= 0
          return [seg]
        elsif st1 >= 0 # st2 < 0
          return [ray.p1] if ray.p1 == seg.p1
          return [Segment.new(ray.p1, seg.p1)]
        elsif st2 >= 0 # st1 < 0
          return [ray.p1] if ray.p1 == seg.p2
          return [Segment.new(ray.p1, seg.p2)]
        end
      end

      def intersect_parallel_segments(seg1, seg2)
        return [seg2] if seg1.contains?(seg2)       
        return [seg1] if seg2.contains?(seg1)
            
        # direct the segments so they're oriented the same way
        if seg1.direction.dot(seg2.direction) < 0
          seg2 = Segment.new(seg2.p2, seg2.p1)
        end

        # order the segments so seg1 is "behind" seg2
        if seg1.span_test(seg2.p1) < 0
          seg1, seg2 = seg2, seg1
        end

        return []         if seg2.span_test(seg1.p2) < 0
        return [seg2.p1]  if seg2.p1 == seg1.p2

        [Segment.new(seg2.p1, seg1.p2)]
      end

      def check_input_points!
        @p1 = Point.new(p1[0], p1[1]) if p1.is_a?(Array)
        raise TypeError, "Point should be array or instance of class Point." unless p1.is_a?(Point)
          
        @p2 = Point.new(p2[0], p2[1]) if p2.is_a?(Array)
        raise TypeError, "Point should be array or instance of class Point." unless p2.is_a?(Point) 
      end

      def validate!
        raise ArgumentError, "Segment requires two unique Points." if p1 == p2
      end
    end
  end
end
