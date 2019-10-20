module EasyGeometry
  module D2
    # A two-dimensional polygon.
    # A simple polygon in space. Can be constructed from a sequence of points
    # 
    # Polygons are treated as closed paths rather than 2D areas so
    # some calculations can be be negative or positive (e.g., area)
    # based on the orientation of the points.

    # Any consecutive identical points are reduced to a single point
    # and any points collinear and between two points will be removed
    # unless they are needed to define an explicit intersection (see specs).

    # Must be at least 4 points
    class Polygon
      attr_reader :vertices

      def initialize(*args)
        @vertices = preprocessing_args(args)
        remove_consecutive_duplicates
        remove_collinear_points
      end

      # Return True/False for cw/ccw orientation.
      def self.is_right?(a, b, c)
        raise TypeError, 'Must pass only Point objects' unless a.is_a?(Point)
        raise TypeError, 'Must pass only Point objects' unless b.is_a?(Point)
        raise TypeError, 'Must pass only Point objects' unless c.is_a?(Point)

        ba = b - a
        ca = c - a
        t_area = ba.x * ca.y - ca.x * ba.y

        t_area <= 0
      end

      # Returns True if self and other are the same mathematical entities
      def ==(other)
        return false unless other.is_a?(Polygon)
        self.hashable_content == other.hashable_content
      end

      # The area of the polygon.
      # The area calculation can be positive or negative based on the
      # orientation of the points. If any side of the polygon crosses
      # any other side, there will be areas having opposite signs.
      def area
        return @area if defined?(@area)

        sum = 0.0
        (0...vertices.length).each do |i|
          prev = vertices[i - 1]
          curr = vertices[i]

          sum += ((prev.x * curr.y) - (prev.y * curr.x))
        end

        @area = sum / 2
        @area
      end

      # The perimeter of the polygon.
      def perimeter
        return @perimeter if defined?(@perimeter)

        @perimeter = 0.0
        (0...vertices.length).each do |i|
          @perimeter += vertices[i - 1].distance(vertices[i])
        end

        @perimeter
      end

      # The centroid of the polygon.
      # 
      # Returns
      #   Point
      # 
      def centroid
        return @centroid if defined?(@centroid)

        cx, cy = 0, 0

        (0...vertices.length).each do |i|
          prev = vertices[i - 1]
          curr = vertices[i]

          v = prev.x * curr.y - curr.x * prev.y
          cx += v * (prev.x + curr.x)
          cy += v * (prev.y + curr.y)
        end

        @centroid = Point.new(Rational(cx, 6 * self.area), Rational(cy, 6 * self.area))
        @centroid
      end

      # The directed line segments that form the sides of the polygon.
      # 
      # Returns
      #   Array of Segments
      # 
      def sides
        return @sides if defined?(@sides)

        @sides = []
        (-vertices.length...0).each do |i|
          @sides << Segment.new(vertices[i], vertices[i + 1])
        end

        @sides
      end

      # Return an array (xmin, ymin, xmax, ymax) representing the bounding
      # rectangle for the geometric figure.
      # 
      # Returns:
      #   array
      #
      def bounds
        return @bounds if defined?(@bounds)

        xs = vertices.map(&:x)
        ys = vertices.map(&:y)
        @bounds = [xs.min, ys.min, xs.max, ys.max]

        @bounds
      end

      # Is the polygon convex?
      # A polygon is convex if all its interior angles are less than 180
      # degrees and there are no intersections between sides.
      # 
      # Returns
      #   True if this polygon is convex
      #   False otherwise.
      # 
      def is_convex?
        cw = Polygon.is_right?(vertices[-2], vertices[-1], vertices[0])
        (1...vertices.length).each do |i|
          if cw ^ Polygon.is_right?(vertices[i - 2], vertices[i - 1], vertices[i])
            return false
          end
        end

        # check for intersecting sides
        sides = self.sides
        sides.each_with_index do |si, i|
          points = [si.p1, si.p2]

          first_number = 0
          first_number = 1 if i == sides.length - 1
          (first_number...i - 1).each do |j|
            sj = sides[j]
            if !points.include?(sj.p1) && !points.include?(sj.p2)
              hit = si.intersection(sj)
              return false if !hit.empty?
            end
          end
        end
                         
        return true
      end

      # Return True if p is enclosed by (is inside of) self, False otherwise.
      # Being on the border of self is considered False.
      # 
      # Parameters:
      #   Point
      # 
      # Returns:
      #   bool
      # 
      # http://paulbourke.net/geometry/polygonmesh/#insidepoly
      def is_encloses_point?(point)
        point = Point.new(point[0], point[1]) if point.is_a?(Array)
        raise TypeError, 'Must pass only Point objects' unless point.is_a?(Point)

        return false if vertices.include?(point)

        sides.each do |s|
          return false if s.contains?(point)
        end

        # move to point, checking that the result is numeric
        lit = []
        vertices.each do |v|
          lit << v - point
        end

        poly = Polygon.new(*lit)
        # polygon closure is assumed in the following test but Polygon removes duplicate pts so
        # the last point has to be added so all sides are computed. Using Polygon.sides is
        # not good since Segments are unordered.
        args = poly.vertices
        indices = (-args.length..0).to_a

        if poly.is_convex?
          orientation = nil
          indices.each do |i|
            a = args[i]
            b = args[i + 1]
            test = ((-a.y)*(b.x - a.x) - (-a.x)*(b.y - a.y)) < 0
            
            if orientation.nil?
              orientation = test
            elsif test != orientation
              return false
            end
          end

          return true
        end

        hit_odd = false
        p1x, p1y = args[0].x, args[0].y
        indices[1..-1].each do |i|
          p2x, p2y = args[i].x, args[i].y

          if [p1y, p2y].min < 0 && [p1y, p2y].max >= 0 && 
            [p1x, p2x].max >= 0 && p1y != p2y

            xinters = (-p1y)*(p2x - p1x)/(p2y - p1y) + p1x
            hit_odd = !hit_odd if p1x == p2x or 0 <= xinters            
          end 

          p1x, p1y = p2x, p2y
        end

        return hit_odd
      end

      # The intersection of polygon and geometry entity.
      # 
      # The intersection may be empty and can contain individual Points and
      # complete Line Segments.
      def intersection(other)
        intersection_result = []
        
        if other.is_a?(Polygon) 
          k = other.sides 
        else 
          k = [other]
        end

        self.sides.each do |side|
          k.each do |side1|
            intersection_result += side.intersection(side1)
          end
        end

        intersection_result.uniq! do |a|
          if a.is_a?(Point)
            [a.x, a.y]
          else
            [a.p1, a.p2].sort_by {|p| [p.x, p.y]} 
          end
        end
        points = []; segments = []

        intersection_result.each do |entity|
          points << entity    if entity.is_a?(Point)
          segments << entity  if entity.is_a?(Segment)
        end

        if !points.empty? && !segments.empty?
          points_in_segments = []

          points.each do |point|
            segments.each do |segment|
              points_in_segments << point if segment.contains?(point)
            end
          end

          points_in_segments.uniq! {|a| [a.x, a.y]}
          if !points_in_segments.empty?
            points_in_segments.each do |p|
              points.delete(p)
            end
          end

          return points.sort + segments.sort
        end

        return intersection_result.sort
      end

      # Returns the shortest distance between self and other.
      # 
      # If other is a point, then self does not need to be convex.
      # If other is another polygon self and other must be convex.
      def distance(other)
        other = Point.new(other[0], other[1]) if other.is_a?(Array)

        if other.is_a?(Point)
          dist = BigDecimal('Infinity')
          
          sides.each do |side|
            current = side.distance(other)
            if current == 0
              return 0
            elsif current < dist
              dist = current
            end
          end
          
          return dist

        elsif other.is_a?(Polygon) && self.is_convex? && other.is_convex?
          return do_poly_distance(other)
        end

        raise TypeError, "Distance not handled for #{ other.class }"
      end

      def hashable_content
        d = {}

        s1 = ref_list(self.vertices, d)
        r_nor = rotate_left(s1, least_rotation(s1))

        s2 = ref_list(self.vertices.reverse, d)
        r_rev = rotate_left(s2, least_rotation(s2))

        if (r_nor <=> r_rev) == -1
          r = r_nor
        else
          r = r_rev
        end

        r.map {|order| d[order]}
      end

      private

      # Calculates the least distance between the exteriors of two
      # convex polygons e1 and e2. Does not check for the convexity
      # of the polygons as this is checked by Polygon.#distance.
      # 
      # Method:
      # [1] http://cgm.cs.mcgill.ca/~orm/mind2p.html
      # Uses rotating calipers:
      # [2] https://en.wikipedia.org/wiki/Rotating_calipers
      # and antipodal points:
      # [3] https://en.wikipedia.org/wiki/Antipodal_point
      def do_poly_distance(e2)
        e1 = self

        # Tests for a possible intersection between the polygons and outputs a warning
        e1_center = e1.centroid
        e2_center = e2.centroid
        e1_max_radius = Rational(0)
        e2_max_radius = Rational(0)

        e1.vertices.each do |vertex|
          r = e1_center.distance(vertex)
          e1_max_radius = r if e1_max_radius < r
        end

        e2.vertices.each do |vertex|
          r = e2_center.distance(vertex)
          e2_max_radius = r if e2_max_radius < r          
        end

        center_dist = e1_center.distance(e2_center)
        if center_dist <= e1_max_radius + e2_max_radius
          puts "Polygons may intersect producing erroneous output"
        end

        # Find the upper rightmost vertex of e1 and the lowest leftmost vertex of e2
        e1_ymax = e1.vertices.first
        e2_ymin = e2.vertices.first

        e1.vertices.each do |vertex|
          if vertex.y > e1_ymax.y || (vertex.y == e1_ymax.y && vertex.x > e1_ymax.x)
            e1_ymax = vertex
          end
        end
        
        e2.vertices.each do |vertex|
          if vertex.y < e2_ymin.y || (vertex.y == e2_ymin.y && vertex.x < e2_ymin.x)
            e2_ymin = vertex
          end
        end

        min_dist = e1_ymax.distance(e2_ymin)

        # Produce a dictionary with vertices of e1 as the keys and, for each vertex, the points
        # to which the vertex is connected as its value. The same is then done for e2.

        e1_connections = {}
        e2_connections = {}

        e1.sides.each do |side|
          if e1_connections[side.p1].nil?
            e1_connections[side.p1] = [side.p2]
          else
            e1_connections[side.p1] << side.p2
          end

          if e1_connections[side.p2].nil?
            e1_connections[side.p2] = [side.p1]
          else
            e1_connections[side.p2] << side.p1            
          end
        end

        e2.sides.each do |side|
          if e2_connections[side.p1].nil?
            e2_connections[side.p1] = [side.p2]
          else
            e2_connections[side.p1] << side.p2
          end

          if e2_connections[side.p2].nil?
            e2_connections[side.p2] = [side.p1]
          else
            e2_connections[side.p2] << side.p1
          end
        end

        e1_current = e1_ymax
        e2_current = e2_ymin
        support_line = Line.new([0, 0], [1, 0])

        # Determine which point in e1 and e2 will be selected after e2_ymin and e1_ymax,
        # this information combined with the above produced dictionaries determines the
        # path that will be taken around the polygons

        point1 = e1_connections[e1_ymax][0]
        point2 = e1_connections[e1_ymax][1]
        angle1 = support_line.angle_between(Line.new(e1_ymax, point1))
        angle2 = support_line.angle_between(Line.new(e1_ymax, point2))

        if angle1 < angle2
          e1_next = point1
        elsif angle2 < angle1
          e1_next = point2
        elsif e1_ymax.distance(point1) > e1_ymax.distance(point2)
          e1_next = point2
        else
          e1_next = point1
        end

        point1 = e2_connections[e2_ymin][0]
        point2 = e2_connections[e2_ymin][1]
        angle1 = support_line.angle_between(Line.new(e2_ymin, point1))
        angle2 = support_line.angle_between(Line.new(e2_ymin, point2))

        if angle1 > angle2
          e2_next = point1
        elsif angle2 > angle1
          e2_next = point2
        elsif e2_ymin.distance(point1) > e2_ymin.distance(point2)
          e2_next = point2
        else
          e2_next = point1
        end

        # Loop which determines the distance between anti-podal pairs and updates the
        # minimum distance accordingly. It repeats until it reaches the starting position.

        while true
          e1_angle = support_line.angle_between(Line.new(e1_current, e1_next))
          e2_angle = Math::PI - support_line.angle_between(Line.new(e2_current, e2_next))

          if e1_angle < e2_angle
            support_line = Line.new(e1_current, e1_next)
            e1_segment = Segment.new(e1_current, e1_next)
            min_dist_current = e1_segment.distance(e2_current)

            if min_dist_current < min_dist
              min_dist = min_dist_current
            end

            if e1_connections[e1_next][0] != e1_current
              e1_current = e1_next
              e1_next = e1_connections[e1_next][0]
            else
              e1_current = e1_next
              e1_next = e1_connections[e1_next][1]
            end
          elsif e1_angle > e2_angle
            support_line = Line.new(e2_next, e2_current)
            e2_segment = Segment.new(e2_current, e2_next)
            min_dist_current = e2_segment.distance(e1_current)

            if min_dist_current < min_dist
              min_dist = min_dist_current
            end

            if e2_connections[e2_next][0] != e2_current
              e2_current = e2_next
              e2_next = e2_connections[e2_next][0]
            else
              e2_current = e2_next
              e2_next = e2_connections[e2_next][1]
            end

          else
            support_line = Line.new(e1_current, e1_next)
            e1_segment = Segment.new(e1_current, e1_next)
            e2_segment = Segment.new(e2_current, e2_next)
            min1 = e1_segment.distance(e2_next)
            min2 = e2_segment.distance(e1_next)

            min_dist_current = [min1, min2].min

            if min_dist_current < min_dist
              min_dist = min_dist_current
            end

            if e1_connections[e1_next][0] != e1_current
              e1_current = e1_next
              e1_next = e1_connections[e1_next][0]
            else
              e1_current = e1_next
              e1_next = e1_connections[e1_next][1]
            end

            if e2_connections[e2_next][0] != e2_current
              e2_current = e2_next
              e2_next = e2_connections[e2_next][0]
            else
              e2_current = e2_next
              e2_next = e2_connections[e2_next][1]
            end
          end

          break if e1_current == e1_ymax && e2_current == e2_ymin
        end

        return min_dist
      end

      def ref_list(point_list, d)
        kee = {}
        
        point_list.sort_by {|p| [p.x, p.y]}.each_with_index do |p, i|
          kee[p] = i
          d[i] = p
        end

        point_list.map {|p| kee[p]}
      end

      # Returns the number of steps of left rotation required to
      # obtain lexicographically minimal array.
      # https://en.wikipedia.org/wiki/Lexicographically_minimal_string_rotation
      def least_rotation(x)
        s = x + x                 # Concatenate arrays to it self to avoid modular arithmetic
        f = [-1] * s.length       # Failure function
        k = 0                     # Least rotation of array found so far

        (1...s.length).each do |j|
          sj = s[j]
          i = f[j - k - 1]

          while i != -1 && sj != s[k + i + 1]
            if sj < s[k + i + 1]
              k = j-i-1
            end

            i = f[i]
          end

          if sj != s[k + i + 1]
            if sj < s[k]
              k = j
            end
            
            f[j - k] = -1
          else
            f[j - k] = i + 1
          end
        end

        return k
      end


      # Left rotates a list x by the number of steps specified in y.
      def rotate_left(x, y)
        return [] if x.length == 0
 
        y = y % x.length
        x[y..-1] + x[0...y]
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
        raise ArgumentError, 'Number of vertices should be more than 2' if vertices.length < 3
      end
    end
  end
end

