require 'spec_helper'

RSpec.describe Geometry::D2::Triangle do
  let(:l1) { Geometry::D2::Line.new([0, 0], [1, 1]) }
  let(:t1) { described_class.new([0, 0], [4, 4], [0, 4]) }
  let(:t2) { described_class.new([0, 0], [0, 1], [1, 1]) }
  let(:t3) { described_class.new([0, 0], [1/2r, Math.sqrt(3)/2], [1, 0]) }
  let(:t4) { described_class.new([0, 0], [5, 0], [5/2r, Math.sqrt(75/4r)]) }

  describe '.new' do
    it 'should raise type error if incorrect parameters' do
      expect { described_class.new("1", 0) }.to raise_error(TypeError)
      expect { described_class.new(nil, 0) }.to raise_error(TypeError)
      expect { described_class.new([], 0) }.to raise_error(TypeError)
      expect { described_class.new(l1) }.to raise_error(TypeError)
    end

    it 'should raise argument error if incorrect number of vertices' do
      expect { described_class.new([0, 0], [0, 1]) }.to raise_error(ArgumentError)
      expect { described_class.new([0, 0], [0, 1], [0, 1]) }.to raise_error(ArgumentError)
      expect { described_class.new([0, 0], [0, 1], [1, 1], [2, 2]) }.to raise_error(ArgumentError)
    end

    it 'should remove consecutive duplicates' do
      expect(described_class.new([0, 0], [0, 1], [0, 1], [0, 1], [0, 1], [1, 1], [1, 1]) == t2).to be true
    end
  end

  describe '#is_similar?' do
    it 'should return false if not triangle' do
      expect(t1.is_similar?(l1)).to be false
      expect(t1.is_similar?(5)).to be false
      expect(t1.is_similar?("qwe")).to be false
    end

    it 'should return false if not similar' do
      expect(t1.is_similar?(described_class.new([0, 0], [15, 9], [15, 1]))).to be false
      expect(t1.is_similar?(described_class.new([100, 20], [37, 16], [15, 1]))).to be false
      expect(t1.is_similar?(described_class.new([0, 0], [4, 4], [0.0000001, 4]))).to be false
    end

    it 'should return true if similar' do
      expect(t1.is_similar?(t2)).to be true
      expect(t1.is_similar?(t1)).to be true
      expect(t2.is_similar?(t2)).to be true
      expect(t2.is_similar?(described_class.new([0, 0], [0, 100], [100, 100]))).to be true
      expect(t2.is_similar?(described_class.new([1, 1], [1, 2], [2, 2]))).to be true
    end
  end

  describe '#is_equilateral?' do
    it 'should return false if not equilateral' do
      expect(t1.is_equilateral?).to be false
      expect(t2.is_equilateral?).to be false
    end

    it 'should return true if equilateral' do
      expect(t3.is_equilateral?).to be true
      expect(t4.is_equilateral?).to be true
    end
  end

  describe '#is_isosceles?' do
    it 'should return false if not isosceles' do
      expect(described_class.new([0, 0], [4, 0], [15, 113]).is_equilateral?).to be false
    end

    it 'should return true if isosceles' do
      expect(t1.is_isosceles?).to be true
      expect(t2.is_isosceles?).to be true
      expect(t3.is_isosceles?).to be true
    end
  end

  describe '#is_scalene?' do
    it 'should return false if not scalene' do
      expect(t1.is_scalene?).to be false
      expect(t2.is_scalene?).to be false
      expect(t3.is_scalene?).to be false
    end
    
    it 'should return true if scalene' do
      expect(described_class.new([0, 0], [4, 0], [15, 113]).is_scalene?).to be true
    end
  end

  describe '#is_right?' do
    it 'should return false if not right-angled' do
      expect(t3.is_right?).to be false
      expect(t4.is_right?).to be false
      expect(described_class.new([0, 0], [4, 0], [15, 113]).is_right?).to be false
    end
    
    it 'should return true if right-angled' do
      expect(t1.is_right?).to be true
      expect(t2.is_right?).to be true
    end
  end

  describe '#altitudes' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(5, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 5) }
    let(:triangle) { described_class.new(p1, p2, p3) }

    it 'should return altitudes' do
      altitudes = triangle.altitudes
      expect(altitudes[p1]).to eq(Geometry::D2::Segment.new(p1, Geometry::D2::Point.new(Rational(5, 2), Rational(5, 2)))) 
      expect(altitudes[p2]).to eq(triangle.sides[0])
      expect(altitudes[p3]).to eq(triangle.sides[2])
    end
  end

  describe '#orthocenter' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(5, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 5) }
    let(:triangle) { described_class.new(p1, p2, p3) }

    it 'should return orthocenter' do
      expect(triangle.orthocenter).to eq(p1)
    end
  end

  describe '#circumcenter' do
    it 'should return circumcenter' do
      expect(described_class.new([0, 0], [1, 0], [0, 1]).circumcenter).to eq(Geometry::D2::Point.new(0.5, 0.5))
    end
  end

  describe '#circumradius' do
    it 'should return circumradius' do
      expect(described_class.new([0, 0], [2, 0], [0, 2]).circumradius).to eq(Math.sqrt(2))
    end
  end

  describe '#bisectors' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(5, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 5) }
    let(:triangle1) { described_class.new(p1, p2, p3) }

    let(:p4) { Geometry::D2::Point.new(0, 0) }
    let(:p5) { Geometry::D2::Point.new(1, 0) }
    let(:p6) { Geometry::D2::Point.new(0, 1) }
    let(:triangle2) { described_class.new(p4, p5, p6) }

    it 'should return bisectors' do
      bisectors1 = triangle1.bisectors
      bisectors2 = triangle2.bisectors

      expect(bisectors1[p1]).to eq(Geometry::D2::Segment.new(p1, Geometry::D2::Point.new(Rational(5, 2), Rational(5, 2))))
      expect(bisectors2[p5]).to eq(Geometry::D2::Segment.new(p5, Geometry::D2::Point.new(0, Math.sqrt(2) - 1)))
    end
  end

  describe '#incenter' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(1, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 1) }
    let(:triangle) { described_class.new(p1, p2, p3) }

    it 'should return incenter' do
      expect(triangle.incenter).to eq(Geometry::D2::Point.new(1 - Math.sqrt(2)/2, 1 - Math.sqrt(2)/2))
    end
  end

  describe '#inradius' do
    it 'should return inradius' do
      expect(described_class.new([0, 0], [4, 0], [0, 3]).inradius).to eq(1)
      expect(described_class.new([0, 0], [5, 0], [0, 5]).inradius).to eq(5 - 5 * Math.sqrt(2)/2)
    end
  end

  describe '#exradii' do
    let(:triangle1) { described_class.new([0, 0], [5, 0], [0, 5]) }
    let(:triangle2) { described_class.new([0, 0], [6, 0], [0, 2]) }

    it 'should return exradii' do
      expect((triangle1.exradii[triangle1.sides[2]]).round(14)).to eq((5 * Math.sqrt(2)/2).round(14))
      expect((triangle2.exradii[triangle2.sides[2]]).round(14)).to eq((-2 + Math.sqrt(10)).round(14))
    end
  end

  describe '#medians' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(1, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 1) }
    let(:triangle) { described_class.new(p1, p2, p3) }

    it 'should return medians' do
      expect((triangle.medians[p1])).to eq(Geometry::D2::Segment.new(p1, Geometry::D2::Point.new(0.5, 0.5)))
    end
  end

  describe '#medial' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(1, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 1) }
    let(:triangle) { described_class.new(p1, p2, p3) }

    it 'should return medial' do
      expect((triangle.medial)).to eq(described_class.new(
        Geometry::D2::Point.new(0.5, 0), 
        Geometry::D2::Point.new(0.5, 0.5),
        Geometry::D2::Point.new(0, 0.5), 
      ))
    end
  end

  describe '#eulerline' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(1, 0) }
    let(:p3) { Geometry::D2::Point.new(0, 1) }
    let(:triangle) { described_class.new(p1, p2, p3) }

    it 'should return eulerline' do
      expect((triangle.eulerline)).to eq(Geometry::D2::Line.new(
        Geometry::D2::Point.new(0, 0), 
        Geometry::D2::Point.new(0.5, 0.5),
      ))
    end
  end
end
