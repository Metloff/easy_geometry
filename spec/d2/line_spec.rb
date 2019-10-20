require 'spec_helper'

RSpec.describe EasyGeometry::D2::Line do
  let(:p1) { EasyGeometry::D2::Point.new(0, 0) }
  let(:p2) { EasyGeometry::D2::Point.new(1, 1) }
  let(:l1) { described_class.new([0, 0], [1, 1]) }
  let(:l2) { described_class.new([0, 0], [-1, 1]) }
  let(:l3) { described_class.new([0, 0], [1, 0]) }
  let(:s1) { EasyGeometry::D2::Segment.new([0, 0], [1, 1]) }
  let(:s2) { EasyGeometry::D2::Segment.new([0, 0], [-1, 1]) }
  let(:s3) { EasyGeometry::D2::Segment.new([0, 0], [1, 0]) }
  let(:r1) { EasyGeometry::D2::Ray.new([0, 0], [1, 1]) }
  let(:r2) { EasyGeometry::D2::Ray.new([0, 0], [-1, 1]) }
  let(:r3) { EasyGeometry::D2::Ray.new([0, 0], [1, 0]) }

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

    it 'should create line' do
      expect(described_class.new(p1, [1, 1])).to eq(l1)
      expect(described_class.new([0, 0], p2)).to eq(l1)
      expect(described_class.new(p1, p2)).to eq(l1)
      expect(described_class.new([0, 0], [1, 1])).to eq(l1)
    end
  end

  describe '#direction' do
    it 'should return a correct vector' do
      expect(l1.direction).to eq(EasyGeometry::D2::Vector.new(1, 1))
      expect(l2.direction).to eq(EasyGeometry::D2::Vector.new(-1, 1))
    end
  end

  describe '#angle_between' do
    it 'should raise error if incorrect parameters' do
      expect { l1.angle_between(1) }.to raise_error(TypeError)
      expect { l1.angle_between("") }.to raise_error(TypeError)
      expect { l1.angle_between({}) }.to raise_error(TypeError)
    end

    it 'should return a correct angle' do
      expect(l1.angle_between(l2)).to eq(90 * Math::PI / 180)
      expect(l1.angle_between(s2)).to eq(90 * Math::PI / 180)
      expect(l1.angle_between(r2)).to eq(90 * Math::PI / 180)
 
      expect(l1.angle_between(l1)).to eq(0)
      expect(l1.angle_between(s1)).to eq(0)
      expect(l1.angle_between(r1)).to eq(0)

      expect(l1.angle_between(l3)).to eq((45 * Math::PI / 180))
      expect(l1.angle_between(s3)).to eq((45 * Math::PI / 180))
      expect(l1.angle_between(r3)).to eq((45 * Math::PI / 180))
    end
  end

  describe '#parallel_to?' do
    it 'should raise error if incorrect parameters' do
      expect { l1.parallel_to?(1) }.to raise_error(TypeError)
      expect { l1.parallel_to?("") }.to raise_error(TypeError)
      expect { l1.parallel_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(l1.parallel_to?(l1)).to be true
      expect(l1.parallel_to?(s1)).to be true
      expect(l1.parallel_to?(r1)).to be true
      expect(l3.parallel_to?(described_class.new([6, 6], [12, 6]))).to be true
    end

    it 'should return false' do
      expect(l1.parallel_to?(l2)).to be false
      expect(l1.parallel_to?(s2)).to be false
      expect(l1.parallel_to?(r2)).to be false
      expect(l2.parallel_to?(l3)).to be false
      expect(l3.parallel_to?(described_class.new([6, 6], [12, 6.00001]))).to be false
    end
  end

  describe '#perpendicular_to?' do
    it 'should raise error if incorrect parameters' do
      expect { l1.perpendicular_to?(1) }.to raise_error(TypeError)
      expect { l1.perpendicular_to?("") }.to raise_error(TypeError)
      expect { l1.perpendicular_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(l1.perpendicular_to?(l2)).to be true
      expect(l1.perpendicular_to?(s2)).to be true
      expect(l1.perpendicular_to?(r2)).to be true
      expect(l3.perpendicular_to?(described_class.new(p1, [0, 1]))).to be true
    end

    it 'should return false' do
      expect(l1.perpendicular_to?(l1)).to be false  
      expect(l1.perpendicular_to?(s1)).to be false  
      expect(l1.perpendicular_to?(r1)).to be false  
      expect(l1.perpendicular_to?(l3)).to be false   
      expect(l2.perpendicular_to?(l3)).to be false   
    end
  end

  describe '#similar_to?' do
    it 'should raise error if incorrect parameters' do
      expect { l1.similar_to?(1) }.to raise_error(TypeError)
      expect { l1.similar_to?("") }.to raise_error(TypeError)
      expect { l1.similar_to?({}) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(l1.similar_to?(described_class.new([2, 2], [4, 4]))).to be true
      expect(l1.similar_to?(EasyGeometry::D2::Segment.new([2, 2], [4, 4]))).to be true
      expect(l1.similar_to?(EasyGeometry::D2::Ray.new([2, 2], [4, 4]))).to be true
      expect(l3.similar_to?(described_class.new([10, 0], [40, 0]))).to be true
    end

    it 'should return false' do
      expect(l1.similar_to?(l2)).to be false   
      expect(l1.similar_to?(s2)).to be false   
      expect(l1.similar_to?(r2)).to be false   
      expect(l1.similar_to?(l3)).to be false   
      expect(l2.similar_to?(l3)).to be false   
    end
  end

  describe '#intersection' do
    it 'should raise error if incorrect parameters' do
      expect { l1.intersection(1) }.to raise_error(TypeError)
      expect { l1.intersection("") }.to raise_error(TypeError)
      expect { l1.intersection({}) }.to raise_error(TypeError)
    end

    context 'intersection with a point' do
      it 'should return array with our point' do
        expect(l1.intersection(p1)).to eq([p1])
        expect(l1.intersection(p2)).to eq([p2])
        expect(l1.intersection(EasyGeometry::D2::Point.new(2, 2))).to eq([EasyGeometry::D2::Point.new(2, 2)])
      end

      it 'should return empty array' do
        expect(l2.intersection(p2)).to eq([])
        expect(l3.intersection(p2)).to eq([])
      end
    end

    context 'intersection with a linear entity which lies on our line' do
      let(:s1) { EasyGeometry::D2::Segment.new([10, 10], [20, 20]) }
      let(:r1) { EasyGeometry::D2::Ray.new([10, 10], [20, 20]) }

      it 'should return array with self when intersection with line' do
        expect(l1.intersection(l1)).to eq([l1])
        expect(l2.intersection(l2)).to eq([l2])
        expect(l3.intersection(l3)).to eq([l3])
        expect(l1.intersection(described_class.new([10, 10], [20, 20]))).to eq([l1])
      end


      it 'should return array with linear entity when intersection with no line' do
        expect(l1.intersection(s1)).to eq([s1])
        expect(l1.intersection(r1)).to eq([r1])
      end
    end

    context 'intersection with a linear entity which does not lie on our line' do
      context 'intersection with parallel linear entity' do
        it 'should return empty array' do
          expect(l1.intersection(described_class.new([1, 0], [2, 1]))).to eq([])
          expect(l1.intersection(EasyGeometry::D2::Segment.new([1, 0], [2, 1]))).to eq([])
          expect(l3.intersection(described_class.new([0, 1], [1, 1]))).to eq([])
          expect(l3.intersection(EasyGeometry::D2::Ray.new([0, 1], [1, 1]))).to eq([])
        end
      end

      context 'intersection with not parallel linear entity' do
        it 'should return array with point' do
          expect(l1.intersection(l2)).to eq([p1])
          expect(l1.intersection(l3)).to eq([p1])
          expect(l3.intersection(described_class.new([7, 1], [9, 2]))).to eq([
            EasyGeometry::D2::Point.new(5, 0)
          ])
          expect(l3.intersection(described_class.new([1, 7], [2, 9]))).to eq([
            EasyGeometry::D2::Point.new(-2.5, 0)
          ])
          expect(l3.intersection(EasyGeometry::D2::Segment.new([0, 0], [1, 1]))).to eq([p1])
          expect(l3.intersection(EasyGeometry::D2::Segment.new([-1, -1], [1, 1]))).to eq([p1])
          expect(l3.intersection(EasyGeometry::D2::Ray.new([0, 0], [1, 1]))).to eq([p1])
          expect(l3.intersection(EasyGeometry::D2::Ray.new([-1, -1], [1, 1]))).to eq([p1])
        end

        it 'should return empty array' do
          expect(l3.intersection(EasyGeometry::D2::Segment.new([2, 2], [1, 1]))).to eq([])
          expect(l3.intersection(EasyGeometry::D2::Segment.new([-2, -2], [-1, -1]))).to eq([])

          expect(l3.intersection(EasyGeometry::D2::Ray.new([0, 0.001], [1, 1]))).to eq([])
        end
      end
    end
  end

  describe '#parallel_line' do
    it 'should raise error if incorrect parameters' do
      expect { l1.parallel_line(1) }.to raise_error(TypeError)
      expect { l1.parallel_line("") }.to raise_error(TypeError)
      expect { l1.parallel_line({}) }.to raise_error(TypeError)
    end

    it 'should return a parallel line' do
      expect(l3.parallel_line(p2).parallel_to?(l3)).to be true
    end
  end

  describe '#perpendicular_line' do
    it 'should raise error if incorrect parameters' do
      expect { l1.perpendicular_line(1) }.to raise_error(TypeError)
      expect { l1.perpendicular_line("") }.to raise_error(TypeError)
      expect { l1.perpendicular_line({}) }.to raise_error(TypeError)
    end

    it 'should return a perpendicular line' do
      expect(l3.perpendicular_line(p2).perpendicular_to?(l3)).to be true
    end
  end

  describe '#perpendicular_segment' do
    it 'should raise error if incorrect parameters' do
      expect { l1.perpendicular_segment(1) }.to raise_error(TypeError)
      expect { l1.perpendicular_segment("") }.to raise_error(TypeError)
      expect { l1.perpendicular_segment({}) }.to raise_error(TypeError)
    end

    it 'should return the point if line contains this point' do
      expect(l1.perpendicular_segment(p1)).to eq(p1) 
      expect(l2.perpendicular_segment(p1)).to eq(p1) 
      expect(l3.perpendicular_segment(p1)).to eq(p1) 
    end

    it 'should return a perpendicular segment' do
      expect(l2.perpendicular_segment(p2)).to eq(EasyGeometry::D2::Segment.new(p2, p1)) 
    end
  end

  describe '#slope' do
    it 'should return a number' do
      expect(l1.slope).to eq(1)
      expect(l3.slope).to eq(0)
      expect(described_class.new(p1, [0, 2]).slope).to eq(BigDecimal('Infinity'))
    end
  end

  describe '#span_test' do
    it 'should raise error if incorrect parameters' do
      expect { l1.span_test(1) }.to raise_error(TypeError)
      expect { l1.span_test("") }.to raise_error(TypeError)
      expect { l1.span_test({}) }.to raise_error(TypeError)
    end

    it 'should return correct number' do
      expect(l1.span_test(p1)).to eq(0)
      expect(l1.span_test(p2)).to eq(1)
      expect(l1.span_test(EasyGeometry::D2::Point.new(-1, -1))).to eq(-1)
    end
  end

  describe '#contains?' do
    it 'should return true' do
      expect(l1.contains?(p1)).to be true
      expect(l1.contains?(p2)).to be true
      expect(l1.contains?(EasyGeometry::D2::Point.new(100, 100))).to be true
      expect(l1.contains?(EasyGeometry::D2::Segment.new(
        [1000, 1000], [2000, 2000]
      ))).to be true
      expect(l1.contains?(EasyGeometry::D2::Ray.new(
        [-1000, -1000], [2000, 2000]
      ))).to be true
    end

    it 'should return false' do
      expect(l1.contains?(EasyGeometry::D2::Point.new(2, 3))).to be false
      expect(l1.contains?(EasyGeometry::D2::Point.new(0, 0.1))).to be false
      expect(l1.contains?(EasyGeometry::D2::Segment.new(
        [1000.1, 1000], [2000, 2000]
      ))).to be false
      expect(l1.contains?(EasyGeometry::D2::Ray.new(
        [-1000, -1001], [2000, 2000]
      ))).to be false
      expect(l1.contains?(2)).to be false
      expect(l1.contains?("")).to be false
    end
  end

  describe '#distance' do
    it 'should raise error if incorrect parameters' do
      expect { l1.distance(1) }.to raise_error(TypeError)
      expect { l1.distance("") }.to raise_error(TypeError)
      expect { l1.distance({}) }.to raise_error(TypeError)
    end

    it 'should return zero if line contains point' do
      expect(l1.distance(p1)).to eq(0) 
      expect(l1.distance(p2)).to eq(0) 
      expect(l2.distance(p1)).to eq(0) 
      expect(l3.distance(p1)).to eq(0) 
    end

    it 'should return correct number' do
      expect(l1.distance([-1, 1])).to eq(Math.sqrt(2))
      expect(l1.distance([1, -1])).to eq(Math.sqrt(2))
      expect(l3.distance([10, 10])).to eq(10)
    end
  end

  describe '#==' do
    it 'should return false if argument is not line' do
      expect(l1 == p1).to be false
      expect(l1 == '').to be false
      expect(l1 == 2).to be false
      expect(l1 == EasyGeometry::D2::Segment.new([0, 0], [1, 1])).to be false
    end

    it 'should return false if not equal' do
      expect(l1 == l2).to be false
      expect(l1 == l3).to be false
    end

    it 'should return false if equal' do
      expect(l1 == l1).to be true
      expect(l1 == EasyGeometry::D2::Line.new([-1, -1], [100, 100])).to be true
    end
  end
end
