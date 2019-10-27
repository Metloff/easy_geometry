require 'spec_helper'

RSpec.describe EasyGeometry::D2::Ray do
  let(:p1) { EasyGeometry::D2::Point.new(0, 0) }
  let(:p2) { EasyGeometry::D2::Point.new(1, 1) }
  let(:p3) { EasyGeometry::D2::Point.new(1, 0) }
  let(:s1) { EasyGeometry::D2::Segment.new([0, 0], [1, 1]) }
  let(:s2) { EasyGeometry::D2::Segment.new([0, 0], [-1, 1]) }
  let(:s3) { EasyGeometry::D2::Segment.new([0, 0], [1, 0]) }
  let(:l1) { EasyGeometry::D2::Line.new([0, 0], [1, 1]) }
  let(:l2) { EasyGeometry::D2::Line.new([0, 0], [-1, 1]) }
  let(:l3) { EasyGeometry::D2::Line.new([0, 0], [1, 0]) }
  let(:r1) { described_class.new([0, 0], [1, 1]) }
  let(:r2) { described_class.new([0, 0], [-1, 1]) }
  let(:r3) { described_class.new([0, 0], [1, 0]) }

  describe '.new' do
    it 'should raise type error if incorrect parameters' do
      expect { described_class.new("1", 0) }.to raise_error(TypeError)
      expect { described_class.new(nil, 0) }.to raise_error(TypeError)
      expect { described_class.new({}, 0) }.to raise_error(TypeError)
    end

    it 'should raise argument error if two points are equal' do
      expect { described_class.new([0, 0], [0, 0]) }.to raise_error(ArgumentError)
      expect { described_class.new([1, 1], [1, 1]) }.to raise_error(ArgumentError)
      expect { described_class.new(EasyGeometry::D2::Point.new(2, 2), EasyGeometry::D2::Point.new(2, 2)) }.to raise_error(ArgumentError)
    end

    it 'should create ray' do
      expect(described_class.new(p1, [1, 1])).to eq(r1)
      expect(described_class.new([0, 0], p2)).to eq(r1)
      expect(described_class.new(p1, p2)).to eq(r1)
      expect(described_class.new([0, 0], [1, 1])).to eq(r1)
    end
  end

  describe '#direction' do
    it 'should return a correct vector' do
      expect(r1.direction).to eq(EasyGeometry::D2::Vector.new(1, 1))
      expect(r2.direction).to eq(EasyGeometry::D2::Vector.new(-1, 1))
    end
  end

  describe '#angle_between' do
    it 'should raise error if incorrect parameters' do
      expect { r1.angle_between(1) }.to raise_error(TypeError)
      expect { r1.angle_between('') }.to raise_error(TypeError)
      expect { r1.angle_between({}) }.to raise_error(TypeError)
    end

    it 'should return a correct angle' do
      expect(r1.angle_between(r2)).to eq(90 * Math::PI / 180)
      expect(r1.angle_between(s2)).to eq(90 * Math::PI / 180)
      expect(r1.angle_between(l2)).to eq(90 * Math::PI / 180)

      expect(r1.angle_between(r1)).to eq(0)
      expect(r1.angle_between(l1)).to eq(0)
      expect(r1.angle_between(s1)).to eq(0)

      expect(r1.angle_between(r3)).to eq((45 * Math::PI / 180))
      expect(r1.angle_between(s3)).to eq((45 * Math::PI / 180))
      expect(r1.angle_between(l3)).to eq((45 * Math::PI / 180))
    end
  end

  describe '#parallel_to?' do
    it 'should raise error if incorrect parameters' do
      expect { r1.parallel_to?(1) }.to raise_error(TypeError)
      expect { r1.parallel_to?('') }.to raise_error(TypeError)
      expect { r1.parallel_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(r1.parallel_to?(r1)).to be true
      expect(r1.parallel_to?(s1)).to be true
      expect(r1.parallel_to?(l1)).to be true
      expect(r3.parallel_to?(described_class.new([6, 6], [12, 6]))).to be true
    end

    it 'should return false' do
      expect(r1.parallel_to?(r2)).to be false
      expect(r1.parallel_to?(l2)).to be false
      expect(r1.parallel_to?(s2)).to be false
      expect(r2.parallel_to?(r3)).to be false
      expect(r3.parallel_to?(described_class.new([6, 6], [12, 6.00001]))).to be false
    end
  end

  describe '#perpendicular_to?' do
    it 'should raise error if incorrect parameters' do
      expect { r1.perpendicular_to?(1) }.to raise_error(TypeError)
      expect { r1.perpendicular_to?('') }.to raise_error(TypeError)
      expect { r1.perpendicular_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(r1.perpendicular_to?(r2)).to be true
      expect(r1.perpendicular_to?(s2)).to be true
      expect(r1.perpendicular_to?(l2)).to be true
      expect(r3.perpendicular_to?(described_class.new(p1, [0, 1]))).to be true
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
      expect { r1.similar_to?(1) }.to raise_error(TypeError)
      expect { r1.similar_to?('') }.to raise_error(TypeError)
      expect { r1.similar_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(r1.similar_to?(described_class.new([2, 2], [4, 4]))).to be true
      expect(r1.similar_to?(EasyGeometry::D2::Line.new([2, 2], [4, 4]))).to be true
      expect(r1.similar_to?(EasyGeometry::D2::Segment.new([2, 2], [4, 4]))).to be true
      expect(r3.similar_to?(described_class.new([10, 0], [40, 0]))).to be true
    end

    it 'should return false' do
      expect(r1.similar_to?(r2)).to be false
      expect(r1.similar_to?(s2)).to be false
      expect(r1.similar_to?(l2)).to be false
      expect(r1.similar_to?(r3)).to be false
      expect(r2.similar_to?(r3)).to be false
    end
  end

  describe '#intersection' do
    it 'should raise error if incorrect parameters' do
      expect { r1.intersection(1) }.to raise_error(TypeError)
      expect { r1.intersection('') }.to raise_error(TypeError)
      expect { r1.intersection({}) }.to raise_error(TypeError)
    end

    context 'intersection with a point' do
      it 'should return array with our point' do
        expect(r1.intersection(p1)).to eq([p1])
        expect(r1.intersection(p2)).to eq([p2])
        expect(r1.intersection([55, 55])).to eq([EasyGeometry::D2::Point.new(55, 55)])
      end

      it 'should return empty array' do
        expect(r3.intersection(p2)).to eq([])
        expect(r3.intersection(p2)).to eq([])
      end
    end

    context 'intersection with a linear entity which lies on one line' do
      it 'should return array with self when intersection with line' do
        expect(r1.intersection(l1)).to eq([r1])
        expect(r2.intersection(l2)).to eq([r2])
        expect(r3.intersection(l3)).to eq([r3])
        expect(r1.intersection(EasyGeometry::D2::Line.new([10, 10], [20, 20]))).to eq([r1])
      end

      it 'should return array with results when intersection with no line' do
        expect(r1.intersection(r1)).to eq([r1])
        expect(r1.intersection(described_class.new([0.5, 0.5], [2, 2]))).to eq([
          described_class.new([0.5, 0.5], [2, 2])
        ])
        expect(r1.intersection(described_class.new([-1, -1], [2, 2]))).to eq([r1])
        expect(r1.intersection(described_class.new([0, 0], [-2, -2]))).to eq([p1])
        expect(r1.intersection(described_class.new([-1, -1], [-2, -2]))).to eq([])
    
        expect(r1.intersection(EasyGeometry::D2::Segment.new([-1, -1], [0, 0]))).to eq([p1])
        expect(described_class.new([0, 0], [-2, -2]).intersection(s1)).to eq([p1])
        expect(r1.intersection(s1)).to eq([s1])
        expect(described_class.new(p2, p1).intersection(s1)).to eq([s1])
        expect(described_class.new([0.5, 0.5], p2).intersection(s1)).to eq([
          EasyGeometry::D2::Segment.new([0.5, 0.5], p2)
        ])
        expect(described_class.new([0.5, 0.5], p1).intersection(s1)).to eq([
          EasyGeometry::D2::Segment.new([0.5, 0.5], p1)
        ])
        expect(described_class.new([2, 2], [9, 9]).intersection(s1)).to eq([])
      end
    end

    context 'intersection with a linear entity which does not lie on one line' do
      context 'intersection with parallel linear entity' do
        it 'should return empty array' do
          expect(r1.intersection(described_class.new([1, 0], [2, 1]))).to eq([])
          expect(r1.intersection(EasyGeometry::D2::Line.new([1, 0], [2, 1]))).to eq([])
          expect(r3.intersection(described_class.new([0, 1], [1, 1]))).to eq([])
          expect(r3.intersection(EasyGeometry::D2::Segment.new([0, 1], [1, 1]))).to eq([])
        end
      end

      context 'intersection with not parallel linear entity' do
        it 'should return array with point' do
          expect(r1.intersection(s2)).to eq([p1])
          expect(r1.intersection(l2)).to eq([p1])
          expect(r1.intersection(r2)).to eq([p1])
          expect(r1.intersection(s3)).to eq([p1])
          expect(r1.intersection(l3)).to eq([p1])
          expect(r1.intersection(r3)).to eq([p1])

          expect(described_class.new([0, 0], [10, 0]).intersection(described_class.new([3, -1], [9, 2]))).to eq([
            EasyGeometry::D2::Point.new(5, 0)
          ])
          expect(described_class.new([0, 0], [10, 0]).intersection(described_class.new([9, 2], [3, -1]))).to eq([
            EasyGeometry::D2::Point.new(5, 0)
          ])
          expect(described_class.new([-10, 0], [10, 0]).intersection(described_class.new([-3, -1], [2, 9]))).to eq([
            EasyGeometry::D2::Point.new(-2.5, 0)
          ])

          expect(s3.intersection(EasyGeometry::D2::Ray.new([0, -1], [1, 1]))).to eq([
            EasyGeometry::D2::Point.new(0.5, 0)
          ])
          expect(EasyGeometry::D2::Segment.new([-10, 0], [10, 0]).intersection(described_class.new([-3, 0.9], [1, 0.3]))).to eq([
            EasyGeometry::D2::Point.new(3, 0)
          ])
          expect(s3.intersection(EasyGeometry::D2::Ray.new([0.2, 0.2], [0.1, 0.1]))).to eq([p1])
        end

        it 'should return empty array' do
          expect(r3.intersection(described_class.new([0, 0.001], [1, 1]))).to eq([])
          expect(r3.intersection(described_class.new([-1, -1], [-1, 2]))).to eq([])

          expect(r3.intersection(EasyGeometry::D2::Segment.new([-0.001, 0], [-0.001, 2]))).to eq([])
          expect(r3.intersection(EasyGeometry::D2::Segment.new([1, 1], [4, 0.0001]))).to eq([])
        end
      end
    end
  end

  describe '#parallel_line' do
    it 'should raise error if incorrect parameters' do
      expect { r1.parallel_line(1) }.to raise_error(TypeError)
      expect { r1.parallel_line('') }.to raise_error(TypeError)
      expect { r1.parallel_line({}) }.to raise_error(TypeError)
    end

    it 'should return a parallel line' do
      expect(r3.parallel_line(p2).parallel_to?(r3)).to be true
    end
  end

  describe '#perpendicular_line' do
    it 'should raise error if incorrect parameters' do
      expect { r1.perpendicular_line(1) }.to raise_error(TypeError)
      expect { r1.perpendicular_line('') }.to raise_error(TypeError)
      expect { r1.perpendicular_line({}) }.to raise_error(TypeError)
    end

    it 'should return a perpendicular line' do
      expect(r3.perpendicular_line(p2).perpendicular_to?(r3)).to be true
    end
  end

  describe '#perpendicular_segment' do
    it 'should raise error if incorrect parameters' do
      expect { r1.perpendicular_segment(1) }.to raise_error(TypeError)
      expect { r1.perpendicular_segment('') }.to raise_error(TypeError)
      expect { r1.perpendicular_segment({}) }.to raise_error(TypeError)
    end

    it 'should return the point if ray contains this point' do
      expect(r1.perpendicular_segment(p1)).to eq(p1)
      expect(r2.perpendicular_segment(p1)).to eq(p1)
      expect(r3.perpendicular_segment(p1)).to eq(p1)
    end

    it 'should return a perpendicular segment' do
      expect(r2.perpendicular_segment(p2)).to eq(EasyGeometry::D2::Segment.new(p2, p1))
      expect(r3.perpendicular_segment(p2)).to eq(EasyGeometry::D2::Segment.new(p2, p3))
      expect(r3.perpendicular_segment(EasyGeometry::D2::Point.new(2, 2))).to eq(
        EasyGeometry::D2::Segment.new(
          EasyGeometry::D2::Point.new(2, 2), 
          EasyGeometry::D2::Point.new(2, 0)
        )
      )
    end
  end

  describe '#slope' do
    it 'should return a number' do
      expect(r1.slope).to eq(1)
      expect(r3.slope).to eq(0)
      expect(described_class.new(p1, [0, 2]).slope).to eq(BigDecimal('Infinity'))
    end
  end

  describe '#span_test' do
    it 'should raise error if incorrect parameters' do
      expect { r1.span_test(1) }.to raise_error(TypeError)
      expect { r1.span_test('') }.to raise_error(TypeError)
      expect { r1.span_test({}) }.to raise_error(TypeError)
    end

    it 'should return correct number' do
      expect(r1.span_test(p1)).to eq(0)
      expect(r1.span_test(p2)).to eq(1)
      expect(r1.span_test(EasyGeometry::D2::Point.new(-1, -1))).to eq(-1)
    end
  end

  describe '#contains?' do
    it 'should contains point' do
      expect(r1.contains?(p1)).to be true
      expect(r1.contains?(p2)).to be true
      expect(r1.contains?([0.5, 0.5])).to be true
      expect(r1.contains?([0.0123, 0.0123])).to be true
      expect(r1.contains?([125, 125])).to be true
    end

    it 'shouldnt contains point' do
      expect(r1.contains?(p3)).to be false
      expect(r3.contains?(p2)).to be false
      expect(r3.contains?([-0.000001, 0])).to be false
      expect(r3.contains?([-1, 0])).to be false
      expect(r3.contains?([20, 20])).to be false
    end

    it 'should contains ray' do
      expect(r1.contains?(r1)).to be true
      expect(r1.contains?(described_class.new([20, 20], [900, 900]))).to be true
      expect(r1.contains?(described_class.new([0.1, 0.1], [0.3, 0.3]))).to be true
      expect(described_class.new([-2, -2], [9, 9]).contains?(r1)).to be true
      expect(described_class.new([0, 0], [0.1, 0.1]).contains?(r1)).to be true
    end

    it 'should not contains ray' do
      expect(r1.contains?(r2)).to be false
      expect(r1.contains?(r3)).to be false
      expect(r1.contains?(described_class.new([0, 0], [1, 1.1]))).to be false
    end

    it 'should contains segment' do
      expect(r1.contains?(s1)).to be true

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [271, 271], [373, 373]
      ))).to be true

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [0.01, 0.01], [0.999, 0.999]
      ))).to be true

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [0.5, 0.5], [0.6, 0.6]
      ))).to be true

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [0.5555551, 0.5555551], [0.5555552, 0.5555552]
      ))).to be true

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [0.5555551, 0.5555551], [0.5555552, 0.5555552]
      ))).to be true
    end

    it 'should not contains segment' do
      expect(r1.contains?(s2)).to be false
      expect(r1.contains?(s3)).to be false

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [-1, -1], [2, 2]
      ))).to be false

      expect(r1.contains?(EasyGeometry::D2::Segment.new(
        [0, 0], [1, 1.000001]
      ))).to be false
    end

    it 'should return false' do
      expect(r1.contains?(2)).to be false
      expect(r1.contains?('')).to be false
    end
  end

  describe '#distance' do
    it 'should raise error if incorrect parameters' do
      expect { r1.distance(1) }.to raise_error(TypeError)
      expect { r1.distance('') }.to raise_error(TypeError)
      expect { r1.distance({}) }.to raise_error(TypeError)
    end

    it 'should return 0' do
      expect(r1.distance(p1)).to eq(0)
      expect(r1.distance(p2)).to eq(0)
      expect(r1.distance(EasyGeometry::D2::Point.new(1000, 1000))).to eq(0)
    end

    it 'should return correct number' do
      expect(r1.distance([-1, -1])).to eq(Math.sqrt(2))
      expect(r1.distance(EasyGeometry::D2::Point.new(-1, 1))).to eq(Math.sqrt(2))
    end
  end

  describe '#==' do
    it 'should return false if argument is not a ray' do
      expect(r1 == p1).to be false
      expect(r1 == '').to be false
      expect(r1 == 2).to be false
      expect(r1 == l1).to be false
      expect(r1 == s1).to be false
    end

    it 'should not be equal' do
      expect(r1 == r2).to be false
      expect(r1 == r3).to be false
      expect(r1 == EasyGeometry::D2::Ray.new(
        [-1, -1], [1, 1]
      )).to be false
    end

    it 'should be equal' do
      expect(r1 == r1).to be true
      expect(r1 == EasyGeometry::D2::Ray.new([0, 0], [100, 100])).to be true
      expect(r3 == r3).to be true
    end
  end

  describe '#xdirection' do
    it 'should return a number' do
      expect(described_class.new([0, 0], [0, 2]).xdirection).to eq (0)
      expect(described_class.new([0, 0], [-1, 2]).xdirection).to eq (-BigDecimal('Infinity'))
      expect(r3.xdirection).to eq (BigDecimal('Infinity'))
    end
  end

  describe '#ydirection' do
    it 'should return a number' do
      expect(r3.ydirection).to eq (0)
      expect(r1.ydirection).to eq (BigDecimal('Infinity'))
      expect(described_class.new([0, 0], [-1, -2]).ydirection).to eq (-BigDecimal('Infinity'))
    end
  end
end
