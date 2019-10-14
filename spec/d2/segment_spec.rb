require 'spec_helper'

RSpec.describe Geometry::D2::Segment do
  let(:p1) { Geometry::D2::Point.new(0, 0) }
  let(:p2) { Geometry::D2::Point.new(1, 1) }
  let(:p3) { Geometry::D2::Point.new(1, 0) }
  let(:s1) { described_class.new([0, 0], [1, 1]) }
  let(:s2) { described_class.new([0, 0], [-1, 1]) }
  let(:s3) { described_class.new([0, 0], [1, 0]) }
  let(:l1) { Geometry::D2::Line.new([0, 0], [1, 1]) }
  let(:l2) { Geometry::D2::Line.new([0, 0], [-1, 1]) }
  let(:l3) { Geometry::D2::Line.new([0, 0], [1, 0]) }
  let(:r1) { Geometry::D2::Ray.new([0, 0], [1, 1]) }
  let(:r2) { Geometry::D2::Ray.new([0, 0], [-1, 1]) }
  let(:r3) { Geometry::D2::Ray.new([0, 0], [1, 0]) }

  describe '.new' do
    it 'should raise type error if incorrect parameters' do
      expect { described_class.new('1', 0) }.to raise_error(TypeError)
      expect { described_class.new(nil, 0) }.to raise_error(TypeError)
      expect { described_class.new({}, 0) }.to raise_error(TypeError)
    end

    it 'should raise argument error if two points are equal' do
      expect { described_class.new([0, 0], [0, 0]) }.to raise_error(ArgumentError)
      expect { described_class.new([1, 1], [1, 1]) }.to raise_error(ArgumentError)
      expect { described_class.new(p1, p1)}.to raise_error(ArgumentError)
    end

    it 'should create segment' do
      expect(described_class.new(p1, [1, 1])).to eq(s1)
      expect(described_class.new([0, 0], p2)).to eq(s1)
      expect(described_class.new(p1, p2)).to eq(s1)
      expect(described_class.new([0, 0], [1, 1])).to eq(s1)
    end
  end

  describe '#direction' do
    it 'should return a correct vector' do
      expect(s1.direction).to eq(Geometry::D2::Vector.new(1, 1))
      expect(s2.direction).to eq(Geometry::D2::Vector.new(-1, 1))
    end
  end

  describe '#angle_between' do
    it 'should raise error if incorrect parameters' do
      expect { s1.angle_between(1) }.to raise_error(TypeError)
      expect { s1.angle_between('') }.to raise_error(TypeError)
      expect { s1.angle_between({}) }.to raise_error(TypeError)
    end

    it 'should return a correct angle' do
      expect(s1.angle_between(s2)).to eq(90 * Math::PI / 180)
      expect(s1.angle_between(l2)).to eq(90 * Math::PI / 180)
      expect(s1.angle_between(r2)).to eq(90 * Math::PI / 180)

      expect(s1.angle_between(s1)).to eq(0)
      expect(s1.angle_between(l1)).to eq(0)
      expect(s1.angle_between(r1)).to eq(0)

      expect(s1.angle_between(s3)).to eq((45 * Math::PI / 180))
      expect(s1.angle_between(l3)).to eq((45 * Math::PI / 180))
      expect(s1.angle_between(r3)).to eq((45 * Math::PI / 180))
    end
  end

  describe '#parallel_to?' do
    it 'should raise error if incorrect parameters' do
      expect { s1.parallel_to?(1) }.to raise_error(TypeError)
      expect { s1.parallel_to?('') }.to raise_error(TypeError)
      expect { s1.parallel_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(s1.parallel_to?(s1)).to be true
      expect(s1.parallel_to?(l1)).to be true
      expect(s1.parallel_to?(r1)).to be true
      expect(s3.parallel_to?(described_class.new([6, 6], [12, 6]))).to be true
    end

    it 'should return false' do
      expect(s1.parallel_to?(l2)).to be false
      expect(s1.parallel_to?(r2)).to be false
      expect(s2.parallel_to?(s3)).to be false
      expect(s1.parallel_to?(s2)).to be false
      expect(s3.parallel_to?(described_class.new([6, 6], [12, 6.00001]))).to be false
    end
  end

  describe '#perpendicular_to?' do
    it 'should raise error if incorrect parameters' do
      expect { s1.perpendicular_to?(1) }.to raise_error(TypeError)
      expect { s1.perpendicular_to?('') }.to raise_error(TypeError)
      expect { s1.perpendicular_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(s1.perpendicular_to?(s2)).to be true
      expect(s1.perpendicular_to?(l2)).to be true
      expect(s1.perpendicular_to?(r2)).to be true
      expect(s3.perpendicular_to?(described_class.new(p1, [0, 1]))).to be true
    end

    it 'should return false' do
      expect(s1.perpendicular_to?(s1)).to be false
      expect(s1.perpendicular_to?(l1)).to be false
      expect(s1.perpendicular_to?(r1)).to be false
      expect(s1.perpendicular_to?(l3)).to be false
      expect(s2.perpendicular_to?(l3)).to be false
    end
  end

  describe '#similar_to?' do
    it 'should raise error if incorrect parameters' do
      expect { s1.similar_to?(1) }.to raise_error(TypeError)
      expect { s1.similar_to?('') }.to raise_error(TypeError)
      expect { s1.similar_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(s1.similar_to?(described_class.new([2, 2], [4, 4]))).to be true
      expect(s1.similar_to?(Geometry::D2::Line.new([2, 2], [4, 4]))).to be true
      expect(s1.similar_to?(Geometry::D2::Ray.new([2, 2], [4, 4]))).to be true
      expect(s3.similar_to?(described_class.new([10, 0], [40, 0]))).to be true
    end

    it 'should return false' do
      expect(s1.similar_to?(s2)).to be false
      expect(s1.similar_to?(l2)).to be false
      expect(s1.similar_to?(r2)).to be false
      expect(s1.similar_to?(s3)).to be false
      expect(s2.similar_to?(s3)).to be false
    end
  end

  describe '#intersection' do
    it 'should raise error if incorrect parameters' do
      expect { s1.intersection(1) }.to raise_error(TypeError)
      expect { s1.intersection('') }.to raise_error(TypeError)
      expect { s1.intersection({}) }.to raise_error(TypeError)
    end

    context 'intersection with a point' do
      it 'should return array with our point' do
        expect(s1.intersection(p1)).to eq([p1])
        expect(s1.intersection(p2)).to eq([p2])
        expect(s1.intersection(Geometry::D2::Point.new(0.5, 0.5))).to eq([Geometry::D2::Point.new(0.5, 0.5)])
      end

      it 'should return empty array' do
        expect(s2.intersection(p2)).to eq([])
        expect(s3.intersection(p2)).to eq([])
      end
    end

    context 'intersection with a linear entity which lies on one line' do
      it 'should return array with self when intersection with line' do
        expect(s1.intersection(l1)).to eq([s1])
        expect(s2.intersection(l2)).to eq([s2])
        expect(s3.intersection(l3)).to eq([s3])
        expect(s1.intersection(Geometry::D2::Line.new([10, 10], [20, 20]))).to eq([s1])
      end

      it 'should return array with results when intersection with no line' do
        expect(s1.intersection(s1)).to eq([s1])
        expect(s1.intersection(described_class.new([0.5, 0.5], [2, 2]))).to eq([
          described_class.new([0.5, 0.5], [1, 1])
        ])
        expect(s1.intersection(described_class.new([2, 2], [0.5, 0.5]))).to eq([
          described_class.new([0.5, 0.5], [1, 1])
        ])
        expect(s1.intersection(described_class.new([1, 1], [4, 4]))).to eq([p2])
        expect(s1.intersection(described_class.new([2, 2], [4, 4]))).to eq([])

        expect(s1.intersection(r1)).to eq([s1])
        expect(s1.intersection(Geometry::D2::Ray.new([0.5, 0.5], [2, 2]))).to eq([
          described_class.new([0.5, 0.5], [1, 1])
        ])
        expect(s1.intersection(Geometry::D2::Ray.new([0.5, 0.5], [-1, -1]))).to eq([
          described_class.new([0, 0], [0.5, 0.5])
        ])
        expect(s1.intersection(Geometry::D2::Ray.new([2, 2], [0.5, 0.5]))).to eq([s1])
        expect(s1.intersection(Geometry::D2::Ray.new([1, 1], [6, 6]))).to eq([p2])
        expect(s1.intersection(Geometry::D2::Ray.new([0, 0], [-6, -6]))).to eq([p1])
        expect(s1.intersection(Geometry::D2::Ray.new([0, 0], [6, 6]))).to eq([s1])
        expect(s1.intersection(Geometry::D2::Ray.new([2, 2], [6, 6]))).to eq([])
      end
    end

    context 'intersection with a linear entity which does not lie on one line' do
      context 'intersection with parallel linear entity' do
        it 'should return empty array' do
          expect(s1.intersection(described_class.new([1, 0], [2, 1]))).to eq([])
          expect(s1.intersection(Geometry::D2::Line.new([1, 0], [2, 1]))).to eq([])
          expect(s3.intersection(described_class.new([0, 1], [1, 1]))).to eq([])
          expect(s3.intersection(Geometry::D2::Ray.new([0, 1], [1, 1]))).to eq([])
        end
      end

      context 'intersection with not parallel linear entity' do
        it 'should return array with point' do
          expect(s1.intersection(s2)).to eq([p1])
          expect(s1.intersection(l2)).to eq([p1])
          expect(s1.intersection(r2)).to eq([p1])
          expect(s1.intersection(s3)).to eq([p1])
          expect(s1.intersection(l3)).to eq([p1])
          expect(s1.intersection(r3)).to eq([p1])

          expect(described_class.new([0, 0], [10, 0]).intersection(described_class.new([3, -1], [9, 2]))).to eq([
            Geometry::D2::Point.new(5, 0)
          ])
          expect(described_class.new([0, 0], [10, 0]).intersection(described_class.new([9, 2], [3, -1]))).to eq([
            Geometry::D2::Point.new(5, 0)
          ])
          expect(described_class.new([-10, 0], [10, 0]).intersection(described_class.new([-3, -1], [2, 9]))).to eq([
            Geometry::D2::Point.new(-2.5, 0)
          ])
          expect(described_class.new([0, 0.2], [0.5, -0.1]).intersection(Geometry::D2::Line.new([-12, 0], [12, 0]))).to eq([
            Geometry::D2::Point.new(1/3r, 0)
          ])

          expect(s3.intersection(Geometry::D2::Ray.new([0, -1], [1, 1]))).to eq([
            Geometry::D2::Point.new(0.5, 0)
          ])
          expect(described_class.new([-10, 0], [10, 0]).intersection(Geometry::D2::Ray.new([-3, 0.9], [1, 0.3]))).to eq([
            Geometry::D2::Point.new(3, 0)
          ])
          expect(s3.intersection(Geometry::D2::Ray.new([0.2, 0.2], [0.1, 0.1]))).to eq([p1])
        end

        it 'should return empty array' do
          expect(s3.intersection(Geometry::D2::Segment.new([2, 2], [1, 1]))).to eq([])
          expect(s3.intersection(Geometry::D2::Segment.new([-2, -2], [-1, -1]))).to eq([])
          expect(s3.intersection(Geometry::D2::Segment.new([1.01, -1], [1.01, 4]))).to eq([])
          expect(s3.intersection(Geometry::D2::Segment.new([-0.01, -1], [-0.01, 4]))).to eq([])

          expect(s3.intersection(Geometry::D2::Ray.new([0, 0.001], [1, 1]))).to eq([])
          expect(s3.intersection(Geometry::D2::Ray.new([1.0001, 0], [1.0001, -1]))).to eq([])
        end
      end
    end
  end

  describe '#parallel_line' do
    it 'should raise error if incorrect parameters' do
      expect { s1.parallel_line(1) }.to raise_error(TypeError)
      expect { s1.parallel_line('') }.to raise_error(TypeError)
      expect { s1.parallel_line({}) }.to raise_error(TypeError)
    end

    it 'should return a parallel line' do
      expect(s3.parallel_line(p2).parallel_to?(s3)).to be true
    end
  end

  describe '#perpendicular_line' do
    it 'should raise error if incorrect parameters' do
      expect { s1.perpendicular_line(1) }.to raise_error(TypeError)
      expect { s1.perpendicular_line('') }.to raise_error(TypeError)
      expect { s1.perpendicular_line({}) }.to raise_error(TypeError)
    end

    it 'should return a perpendicular line' do
      expect(s3.perpendicular_line(p2).perpendicular_to?(s3)).to be true
    end
  end

  describe '#perpendicular_segment' do
    it 'should raise error if incorrect parameters' do
      expect { s1.perpendicular_segment(1) }.to raise_error(TypeError)
      expect { s1.perpendicular_segment('') }.to raise_error(TypeError)
      expect { s1.perpendicular_segment({}) }.to raise_error(TypeError)
    end

    it 'should return the point if segment contains this point' do
      expect(s1.perpendicular_segment(p1)).to eq(p1)
      expect(s2.perpendicular_segment(p1)).to eq(p1)
      expect(s3.perpendicular_segment(p1)).to eq(p1)
    end

    it 'should return a perpendicular segment' do
      expect(s2.perpendicular_segment(p2)).to eq(Geometry::D2::Segment.new(p2, p1))
      expect(s3.perpendicular_segment(p2)).to eq(Geometry::D2::Segment.new(p2, p3))
      expect(s3.perpendicular_segment(Geometry::D2::Point.new(2, 2))).to eq(
        Geometry::D2::Segment.new(
          Geometry::D2::Point.new(2, 2), 
          Geometry::D2::Point.new(2, 0)
        )
      )
    end
  end

  describe '#slope' do
    it 'should return a number' do
      expect(s1.slope).to eq(1)
      expect(s3.slope).to eq(0)
      expect(described_class.new(p1, [0, 2]).slope).to eq(BigDecimal('Infinity'))
    end
  end

  describe '#span_test' do
    it 'should raise error if incorrect parameters' do
      expect { s1.span_test(1) }.to raise_error(TypeError)
      expect { s1.span_test('') }.to raise_error(TypeError)
      expect { s1.span_test({}) }.to raise_error(TypeError)
    end

    it 'should return correct number' do
      expect(s1.span_test(p1)).to eq(0)
      expect(s1.span_test(p2)).to eq(1)
      expect(s1.span_test(Geometry::D2::Point.new(-1, -1))).to eq(-1)
    end
  end

  describe '#contains?' do
    it 'should contains point' do
      expect(s1.contains?(p1)).to be true
      expect(s1.contains?(p2)).to be true
      expect(s1.contains?([0.5, 0.5])).to be true
      expect(s1.contains?([0.0123, 0.0123])).to be true
    end

    it 'shouldnt contains point' do
      expect(s1.contains?(p3)).to be false
      expect(s3.contains?(p2)).to be false
      expect(s3.contains?([-0.000001, 0])).to be false
      expect(s3.contains?([1.000001, 0])).to be false
    end

    it 'should contains segment' do
      expect(s1.contains?(Geometry::D2::Segment.new(
        [0.01, 0.01], [0.999, 0.999]
      ))).to be true

      expect(s1.contains?(Geometry::D2::Segment.new(
        [0.5, 0.5], [0.6, 0.6]
      ))).to be true

      expect(s1.contains?(Geometry::D2::Segment.new(
        [0.5555551, 0.5555551], [0.5555552, 0.5555552]
      ))).to be true
    end

    it 'should not contains segment' do
      expect(s1.contains?(Geometry::D2::Segment.new(
        [0, 0], [2, 2]
      ))).to be false

      expect(s1.contains?(Geometry::D2::Segment.new(
        [0, 0], [1.000001, 1.000001]
      ))).to be false

      expect(s1.contains?(Geometry::D2::Segment.new(
        [0.5, 0.5], [1.3, 1.3]
      ))).to be false
    end

    it 'should return false' do
      expect(s1.contains?(Geometry::D2::Ray.new(
        [0, 0], [1, 1]
      ))).to be false

      expect(s1.contains?(2)).to be false
      expect(s1.contains?('')).to be false
    end
  end

  describe '#==' do
    it 'should return false if argument is not segment' do
      expect(s1 == p1).to be false
      expect(s1 == '').to be false
      expect(s1 == 2).to be false
      expect(s1 == l1).to be false
      expect(s1 == r1).to be false
    end

    it 'should not be equal' do
      expect(s1 == s2).to be false
      expect(s1 == s3).to be false
      expect(s1 == Geometry::D2::Segment.new(
        [0.000001, 0.000001], [1, 1]
      )).to be false
    end

    it 'should be equal' do
      expect(s1 == s1).to be true
      expect(s1 == Geometry::D2::Segment.new([0, 0], [1, 1])).to be true
      expect(s3 == s3).to be true
    end
  end

  describe '#distance' do
    it 'should raise error if incorrect parameters' do
      expect { s1.distance(1) }.to raise_error(TypeError)
      expect { s1.distance('') }.to raise_error(TypeError)
      expect { s1.distance({}) }.to raise_error(TypeError)
      expect { s1.distance(l1) }.to raise_error(TypeError)
      expect { s1.distance(r2) }.to raise_error(TypeError)
      expect { s1.distance(s3) }.to raise_error(TypeError)
    end

    it 'should return zero if segment contains point' do
      expect(s1.distance(p1)).to eq(0)
      expect(s1.distance([1, 1])).to eq(0)
      expect(s3.distance(p3)).to eq(0)
      expect(s3.distance([0.5, 0])).to eq(0)
    end

    it 'should return correct number' do
      expect(described_class.new([0.5, 0], p3).distance(p1)).to eq(0.5)
      expect(described_class.new([0.5, 0], p3).distance([1.5, 1.5])).to eq(Math.sqrt(10)/2)
      expect(s1.distance([-1, 1])).to eq(Math.sqrt(2))
    end
  end

  describe '#length' do
    it 'should return a number' do
      expect(s1.length).to eq(Math.sqrt(2))
      expect(s2.length).to eq(Math.sqrt(2))
      expect(s3.length).to eq(1)
    end
  end

  describe '#midpoint' do
    it 'should return a number' do
      expect(s1.midpoint).to eq(Geometry::D2::Point.new(0.5, 0.5))
      expect(s2.midpoint).to eq(Geometry::D2::Point.new(-0.5, 0.5))
      expect(s3.midpoint).to eq(Geometry::D2::Point.new(0.5, 0))
    end
  end

  describe '#perpendicular_bisector' do
    it 'should raise error if incorrect parameters' do
      expect { s1.perpendicular_bisector(1) }.to raise_error(TypeError)
      expect { s1.perpendicular_bisector('') }.to raise_error(TypeError)
      expect { s1.perpendicular_bisector({}) }.to raise_error(TypeError)
      expect { s1.perpendicular_bisector(l1) }.to raise_error(TypeError)
      expect { s1.perpendicular_bisector(r2) }.to raise_error(TypeError)
      expect { s1.perpendicular_bisector(s3) }.to raise_error(TypeError)
    end

    it 'should return perpendicular linear entity' do
      aline = Geometry::D2::Line.new([0.5, 0.5], [1.5, -0.5])
      on_line = described_class.new([0.5, 0.5], [1.5, -0.5]).midpoint

      expect(s1.perpendicular_bisector).to eq(aline)
      expect(s1.perpendicular_bisector(on_line)).to eq(
        described_class.new(on_line, s1.midpoint)
      )
      expect(s1.perpendicular_bisector(on_line + p3)).to eq(aline)
    end
  end
end
