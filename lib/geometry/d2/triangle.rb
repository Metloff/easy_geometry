module Geometry
  module D2
    # A polygon with three vertices and three sides.
    class Triangle < Polygon
      attr_reader :vertices

      EQUITY_TOLERANCE = 0.0000000000001

      def initialize(*args)
        @vertices = preprocessing_args(args)
        remove_consecutive_duplicates
        remove_collinear_points
      end

      # Is another triangle similar to this one.
      # 
      # Parameters:
      #   Triangle
      # 
      # Returns:
      #   bool
      # 
      def is_similar?(other)
        return false unless other.is_a?(Triangle)

        s1_1, s1_2, s1_3 = self.sides.map {|side| side.length}
        s2 = other.sides.map {|side| side.length}

        are_similar?(s1_1, s1_2, s1_3, *s2) ||
        are_similar?(s1_1, s1_3, s1_2, *s2) ||
        are_similar?(s1_2, s1_1, s1_3, *s2) ||
        are_similar?(s1_2, s1_3, s1_1, *s2) ||
        are_similar?(s1_3, s1_1, s1_2, *s2) ||
        are_similar?(s1_3, s1_2, s1_1, *s2)
      end

      # Are all the sides the same length?
      # Precision - 10e-13
      # 
      # Returns:
      #   bool
      # 
      def is_equilateral?
        lengths = self.sides.map { |side| side.length }
        lengths = lengths.map { |l| l - lengths.first }
        return lengths.reject { |l| l.abs < EQUITY_TOLERANCE }.length == 0
      end

      # Are two or more of the sides the same length?
      # 
      # Returns:
      #   bool
      # 
      def is_isosceles?
        has_dups(self.sides.map { |side| side.length })
      end

      # Are all the sides of the triangle of different lengths?
      # 
      # Returns:
      #   bool
      # 
      def is_scalene?
        !has_dups(self.sides.map { |side| side.length })
      end

      # Is the triangle right-angled.
      # 
      # Returns:
      #   bool
      #
      def is_right?
        s = self.sides

        s[0].perpendicular_to?(s[1]) ||
        s[1].perpendicular_to?(s[2]) ||
        s[0].perpendicular_to?(s[2])
      end

      # The altitudes of the triangle.
      # 
      # An altitude of a triangle is a segment through a vertex,
      # perpendicular to the opposite side, with length being the
      # height of the vertex measured from the line containing the side.
      # 
      # Returns:
      #   Hash (The hash consists of keys which are vertices and values
      #     which are Segments.)
      #
      def altitudes
        return @altitudes if defined?(@altitudes)

        @altitudes = { 
          self.vertices[0] =>  self.sides[1].perpendicular_segment(self.vertices[0]),
          self.vertices[1] =>  self.sides[2].perpendicular_segment(self.vertices[1]),
          self.vertices[2] =>  self.sides[0].perpendicular_segment(self.vertices[2])
        }

        @altitudes
      end

      # The orthocenter of the triangle.
      # 
      # The orthocenter is the intersection of the altitudes of a triangle.
      # It may lie inside, outside or on the triangle.
      # 
      # Returns:
      #   Point
      # 
      def orthocenter
        return @orthocenter if defined?(@orthocenter)

        a = self.altitudes
        a1 = a[self.vertices[0]]; a2 = a[self.vertices[1]]
        
        l1 = Line.new(a1.p1, a1.p2)
        l2 = Line.new(a2.p1, a2.p2)

        @orthocenter = l1.intersection(l2)[0]
        @orthocenter
      end

      # The circumcenter of the triangle
      # 
      # The circumcenter is the center of the circumcircle.
      # 
      # Returns:
      #   Point or nil
      # 
      def circumcenter
        return @circumcenter if defined?(@circumcenter)

        a, b, c = self.sides.map { |side| side.perpendicular_bisector }
        
        @circumcenter = a.intersection(b)[0]
        @circumcenter
      end

      # The radius of the circumcircle of the triangle.
      # 
      # Returns:
      #   int
      # 
      def circumradius
        @circumradius ||= self.vertices[0].distance(self.circumcenter)
      end

      # The circle which passes through the three vertices of the triangle.
      # 
      # Returns:
      #   Circle
      # 
      def circumcircle
        # Circle.new(self.circumcenter, self.circumradius)
      end

      # The angle bisectors of the triangle.
      # 
      # An angle bisector of a triangle is a straight line through a vertex
      # which cuts the corresponding angle in half.
      # 
      # Returns:
      #   Hash (each key is a vertex (Point) and each value is the corresponding
      #     bisector (Segment).)
      #
      def bisectors
        s = self.sides.map { |side| Line.new(side.p1, side.p2) }
        c = self.incenter

        inter1 = Line.new(self.vertices[0], c).intersection(s[1]).first
        inter2 = Line.new(self.vertices[1], c).intersection(s[2]).first
        inter3 = Line.new(self.vertices[2], c).intersection(s[0]).first

        {
          self.vertices[0] => Segment.new(self.vertices[0], inter1), 
          self.vertices[1] => Segment.new(self.vertices[1], inter2),
          self.vertices[2] => Segment.new(self.vertices[2], inter3),
        }
      end

      # The center of the incircle.
      # 
      # The incircle is the circle which lies inside the triangle and touches
      # all three sides.
      # 
      # Returns:
      #   Point
      # 
      def incenter
        return @incenter if defined?(@incenter)

        s = self.sides
        l = [1, 2, 0].map { |i| s[i].length }
        p = l.sum

        x_arr = self.vertices.map { |v| v.x / p }
        y_arr = self.vertices.map { |v| v.y / p }

        x = l[0] * x_arr[0] + l[1] * x_arr[1] + l[2] * x_arr[2]
        y = l[0] * y_arr[0] + l[1] * y_arr[1] + l[2] * y_arr[2]

        @incenter = Point.new(x, y)
        @incenter
      end

      # The radius of the incircle.
      # 
      # Returns:
      #   int
      #
      def inradius
        @inradius ||= 2 * self.area / self.perimeter
      end

      # The incircle of the triangle.
      # 
      # The incircle is the circle which lies inside the triangle and touches
      # all three sides.
      # 
      # Returns:
      #   Circle
      #
      def incircle
        # Circle.new(self.incenter, self.inradius)
      end

      # The radius of excircles of a triangle.
      # 
      # An excircle of the triangle is a circle lying outside the triangle,
      # tangent to one of its sides and tangent to the extensions of the
      # other two.
      # 
      # Returns:
      #   Hash
      #
      def exradii
        return @exradii if defined?(@exradii)
        a = self.sides[0].length
        b = self.sides[1].length
        c = self.sides[2].length
        s = (a + b + c) / 2
        area = self.area

        @exradii = {
          self.sides[0] => area / (s - a),
          self.sides[1] => area / (s - b),
          self.sides[2] => area / (s - c)
        }
        @exradii
      end

      # The medians of the triangle.
      # 
      # A median of a triangle is a straight line through a vertex and the
      # midpoint of the opposite side, and divides the triangle into two
      # equal areas.
      # 
      # Returns:
      #   Hash (each key is a vertex (Point) and each value is the median (Segment)
      #     at that point.)
      #
      def medians
        @medians ||= {
          self.vertices[0] => Segment.new(self.vertices[0], self.sides[1].midpoint),
          self.vertices[1] => Segment.new(self.vertices[1], self.sides[2].midpoint),
          self.vertices[2] => Segment.new(self.vertices[2], self.sides[0].midpoint)
        }
      end

      # The medial triangle of the triangle.
      # The triangle which is formed from the midpoints of the three sides.
      # 
      # Returns:
      #   Triangle
      # 
      def medial
        @medial ||= Triangle.new(
          self.sides[0].midpoint, 
          self.sides[1].midpoint, 
          self.sides[2].midpoint
        )
      end

      # The nine-point circle of the triangle.
      # 
      # Nine-point circle is the circumcircle of the medial triangle, which
      # passes through the feet of altitudes and the middle points of segments
      # connecting the vertices and the orthocenter.
      # 
      # Returns:
      #   Circle
      # 
      def nine_point_circle
        # Circle.new(*self.medial.vertices)
      end

      # The Euler line of the triangle.
      # The line which passes through circumcenter, centroid and orthocenter.
      # 
      # Returns:
      #   Line (or Point for equilateral triangles in which case all
      #     centers coincide)
      # 
      def eulerline
        return self.orthocenter if self.is_equilateral?
        Line.new(self.orthocenter, self.circumcenter)
      end

      private

      def has_dups(arr)
        (0...arr.length).each do |i|
          return true if (arr[i] - arr[i - 1]).abs  < EQUITY_TOLERANCE
        end

        return false
      end

      def are_similar?(u1, u2, u3, v1, v2, v3)
        e1 = u1 / v1
        e2 = u2 / v2
        e3 = u3 / v3

        e1 == e2 && e2 == e3
      end

       # preprocessing_args - convert coordinates to points if necessary.
       def preprocessing_args(args)
        args.map do |v|
          if v.is_a?(Array) && v.length == 2
            Point.new(*v)
          elsif v.is_a?(Point)
            v
          else
            raise TypeError, "Arguments should be arrays with coordinates or Points."
          end
        end
      end

      def remove_consecutive_duplicates
        nodup = []        
        @vertices.each do |p|
          next if !nodup.empty? && p == nodup[-1]
          nodup << p
        end

        if nodup.length > 1 && nodup[-1] == nodup[0]
          nodup.pop # last point was same as first
        end

        @vertices = nodup
        validate
      end

      def remove_collinear_points
        i = 0
        while i < vertices.length
          a, b, c = vertices[i], vertices[i - 1], vertices[i - 2]
          if Point.is_collinear?(a, b, c)
            vertices.delete_at(i - 1)
            vertices.delete_at(i - 2) if a == c
          else
            i += 1
          end
        end

        validate
      end

      def validate
        raise ArgumentError, 'Triangle instantiates with three points' if vertices.length != 3
      end
    end
  end
end
