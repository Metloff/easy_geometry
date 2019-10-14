require 'spec_helper'

RSpec.describe Geometry::D2::Polygon do
  let(:l1) { Geometry::D2::Line.new([0, 0], [1, 1]) }
  let(:poly1) { described_class.new([0, 0], [3, -1], [6, 0], [4, 5], [2, 3], [0, 3]) }
  let(:poly2) { described_class.new([6, 0], [3, -1], [0, 0], [0, 3], [2, 3], [4, 5]) }
  let(:poly3) { described_class.new([0, 0], [3, 0], [5, 2], [4, 4]) }
  let(:poly4) { described_class.new([0, 2], [2, 2], [0, 0], [2, 0]) }
  let(:poly5) { described_class.new([0, 0], [0, 1], [1, 1], [1, 0]) }
  let(:poly6) { described_class.new([0, 0], [1, 0], [5, 1], [0, 1]) }


  describe '.new' do
    let(:polygon1) { described_class.new([-15, -15], [15, -15], [15, 15], [-15, 15]) }

    it 'should raise type error if incorrect parameters' do
      expect { described_class.new("1", 0) }.to raise_error(TypeError)
      expect { described_class.new(nil, 0) }.to raise_error(TypeError)
      expect { described_class.new([], 0) }.to raise_error(TypeError)
      expect { described_class.new(l1) }.to raise_error(TypeError)
    end

    it 'should raise argument error if incorrect number of vertices' do
      expect { described_class.new([0, 0], [0, 1]) }.to raise_error(ArgumentError)
      expect { described_class.new([0, 0], [0, 1], [0, 1]) }.to raise_error(ArgumentError)
    end

    it 'should remove consecutive duplicates' do
      expect(described_class.new([0, 0], [0, 1], [0, 1], [0, 1], [0, 1], [1, 1], [1, 1], [1, 0]) == poly5).to be true
    end

    it 'should remove collinear points' do
      expect(described_class.new(
        [-4, 15], [-11, 15], [-15, 15],
        [-15, 33/5], [-15, -87/10], [-15, -15],
        [-42/5, -15], [-2, -15], [7, -15], [15, -15],
        [15, -3], [15, 10], [15, 15]) == polygon1).to be true
    end
  end

  describe '.is_right?' do
    let(:p1) { Geometry::D2::Point.new(0, 0) }
    let(:p2) { Geometry::D2::Point.new(1, 1) }
    let(:p3) { Geometry::D2::Point.new(1, 0) }

    it 'should raise type error if incorrect parameters' do
      expect { described_class.is_right?("1", 0, nil) }.to raise_error(TypeError)
      expect { described_class.is_right?(p1, 0, nil) }.to raise_error(TypeError)
      expect { described_class.is_right?(p1, p2, nil) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(described_class.is_right?(p1, p2, p3)).to be true
    end

    it 'should return false' do
      expect(described_class.is_right?(p1, p3, p2)).to be false
    end
  end

  describe '#==' do
    it 'should return false if argument is not a polygon' do
      expect(poly1 == l1).to be false
      expect(poly1 == '').to be false
      expect(poly1 == 2).to be false
    end

    it 'should be equal' do
      expect(poly1 == poly1).to be true
      expect(poly1 == poly2).to be true
    end

    it 'should not be equal' do
      expect(poly1 == poly3).to be false
      expect(poly2 == poly3).to be false
    end
  end

  describe '#area' do
    it 'should return correct number' do
      expect(poly1.area).to eq(22)
      expect(poly4.area).to eq(0)
      expect(poly5.area.abs).to eq(1)
    end
  end

  describe '#perimeter' do
    it 'should return correct number' do
      expect(poly1.perimeter).to eq(5 + 2 * Math.sqrt(10) + Math.sqrt(29) + Math.sqrt(8))
      expect(poly5.perimeter).to eq(4)
    end
  end

  describe '#centroid' do
    it 'should return correct number' do
      expect(poly6.centroid).to eq(Geometry::D2::Point.new(31/18r, 11/18r))
      expect(poly5.centroid).to eq(Geometry::D2::Point.new(0.5, 0.5))
    end
  end

  describe '#sides' do
    it 'should return correct number of sides' do
      expect(poly1.sides.length).to eq(6)
      expect(poly6.sides.length).to eq(4)
    end

    it 'should return correct array with sides' do
      expect(poly6.sides).to eq([
        Geometry::D2::Segment.new([0, 0], [1, 0]),
        Geometry::D2::Segment.new([1, 0], [5, 1]),
        Geometry::D2::Segment.new([5, 1], [0, 1]),
        Geometry::D2::Segment.new([0, 1], [0, 0]),
      ])
    end
  end

  describe '#bounds' do
    it 'should return correct number' do
      expect(poly1.bounds).to eq([0, -1, 6, 5])
      expect(poly5.bounds).to eq([0, 0, 1, 1])
    end
  end

  describe '#is_convex?' do
    let(:polygon1) { described_class.new([0, 0], [4, 4], [5, 2], [3, 0]) }
    let(:polygon2) { described_class.new([0, 0], [5, 0], [0, 5]) }

    it 'should return true' do
      expect(poly3.is_convex?).to be true
      expect(poly6.is_convex?).to be true
      expect(polygon1.is_convex?).to be true
      expect(polygon2.is_convex?).to be true
    end

    it 'should return false' do
      expect(poly1.is_convex?).to be false
    end
  end

  describe '#is_encloses_point?' do
    let(:polygon1) { described_class.new([0, 0], [4, 4], [0, 4]) }
    let(:polygon2) { described_class.new([0, 0], [0, 2], [4, 4], [8, 2], [8, 0], [4, 2])}

    it 'should raise type error if incorrect parameters' do
      expect { described_class.new("1") }.to raise_error(TypeError)
      expect { described_class.new(nil) }.to raise_error(TypeError)
      expect { described_class.new([]) }.to raise_error(TypeError)
      expect { described_class.new(l1) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(polygon1.is_encloses_point?([1, 3])).to be true
      expect(polygon2.is_encloses_point?([4, 3])).to be true
      expect(polygon2.is_encloses_point?([4, 3.99999])).to be true
    end
    
    it 'should return false' do
      expect(poly1.is_encloses_point?([0, 0])).to be false
      expect(poly1.is_encloses_point?([6, 0])).to be false
      expect(polygon1.is_encloses_point?([2, 2])).to be false
      expect(polygon1.is_encloses_point?([2, 1])).to be false
      expect(polygon1.is_encloses_point?([5, 5])).to be false
      expect(polygon1.is_encloses_point?([0, 0])).to be false
      expect(polygon1.is_encloses_point?([4, 0])).to be false
      expect(polygon2.is_encloses_point?([2, 1])).to be false
      expect(polygon2.is_encloses_point?([4, 4])).to be false
    end
  end

  describe '#intersection' do
    let(:polygon1) { described_class.new([0, 0], [1, 0], [0, 1]) }
    let(:polygon2) { described_class.new([0, 1], [-5, 0], [0, -4], [0, 1/5r], [1/2r, -0.1], [1, 0], [0, 1])}

    context 'with point' do
      it 'intersect' do
        expect(polygon1.intersection(Geometry::D2::Point.new(0, 0))).to eq([Geometry::D2::Point.new(0, 0)])
        expect(polygon1.intersection(Geometry::D2::Point.new(1, 0))).to eq([Geometry::D2::Point.new(1, 0)])
        expect(polygon1.intersection(Geometry::D2::Point.new(0.5, 0))).to eq([Geometry::D2::Point.new(0.5, 0)])
      end
      
      it 'not intersect' do
        expect(polygon1.intersection(Geometry::D2::Point.new(-12, -43))).to eq([])
        expect(polygon1.intersection(Geometry::D2::Point.new(0.1, 0.1))).to eq([])
      end
    end

    context 'with linear entity' do
      it 'intersect' do
        expect(polygon2.intersection(Geometry::D2::Line.new([-12, 0], [12, 0]))).to eq([
          Geometry::D2::Point.new(-5, 0),
          Geometry::D2::Point.new(0, 0),
          Geometry::D2::Point.new(1/3r, 0),
          Geometry::D2::Point.new(1, 0),
        ])

        expect(polygon2.intersection(Geometry::D2::Line.new([-5, 0], [0, 1]))).to eq([
          Geometry::D2::Segment.new([-5, 0], [0, 1]),
        ])

        expect(polygon2.intersection(Geometry::D2::Line.new([0, 0], [0, 1]))).to eq([
          Geometry::D2::Point.new(0, 1),
          Geometry::D2::Segment.new([0, -4], [0, 0.2]),
        ])

        expect(polygon2.intersection(Geometry::D2::Ray.new([-3, 4], [1, 0]))).to eq([
          Geometry::D2::Segment.new([1, 0], [0, 1]),
        ])
      end
      
      it 'not intersect' do
        expect(polygon1.intersection(Geometry::D2::Line.new([-12, 0], [12, 12]))).to eq([])
      end
    end

    context 'with polygon' do
      it 'intersect' do
        expect(polygon1.intersection(polygon2)).to eq([
          Geometry::D2::Point.new(1/3r, 0),
          Geometry::D2::Segment.new([0, 1/5r], [0, 0]),
          Geometry::D2::Segment.new([1, 0], [0, 1]),
        ])

        expect(polygon2.intersection(polygon1)).to eq([
          Geometry::D2::Point.new(1/3r, 0),
          Geometry::D2::Segment.new([0, 0], [0, 1/5r]),
          Geometry::D2::Segment.new([1, 0], [0, 1]),
        ])

        expect(polygon1.intersection(polygon1)).to eq([
          Geometry::D2::Segment.new([0, 0], [1, 0]),
          Geometry::D2::Segment.new([0, 0], [0, 1]),
          Geometry::D2::Segment.new([1, 0], [0, 1]),
        ])

        expect(polygon2.intersection(polygon2)).to eq([
          Geometry::D2::Segment.new([-5, 0], [0, -4]),
          Geometry::D2::Segment.new([0, -4], [0, 1/5r]),
          Geometry::D2::Segment.new([0, 1/5r], [1/2r, -1/10r]),
          Geometry::D2::Segment.new([0, 1], [-5, 0]),
          Geometry::D2::Segment.new([1/2r, -1/10r], [1, 0]),
          Geometry::D2::Segment.new([1, 0], [0, 1]),
        ])

        expect(polygon2.intersection(described_class.new([0, 1], [1, 0], [-1, 1]) )).to eq([
          Geometry::D2::Point.new(-5/7r, 6/7r),
          Geometry::D2::Segment.new([0, 1], [1, 0]),
        ])

        expect(polygon1.intersection(described_class.new([3, 0], [1, 2], [1, 0]))).to eq([
          Geometry::D2::Point.new(1, 0),
        ])

      end
      
      it 'not intersect' do
        expect(polygon1.intersection(described_class.new([3, 0], [1, 2], [1.0004, 0]))).to eq([])
      end
    end
  end

  describe '#distance' do
    let(:polygon1) { described_class.new([0, 0], [1, 0], [1, 1], [0, 1]) }
    let(:polygon2) { described_class.new([0, 5/4r], [1, 5/4r], [1, 9/4r], [0, 9/4r]) }
    let(:polygon3) { described_class.new([1, 2], [2, 2], [2, 1]) }
    let(:polygon4) { described_class.new([1, 1], [6/5r, 1], [1, 6/5r]) }
    let(:polygon5) { described_class.new([0, 0], [4, 4], [0, 4]) }



    it 'should raise TypeError' do
      expect{ poly1.distance(l1) }.to raise_error(TypeError)
      expect{ poly1.distance("") }.to raise_error(TypeError)
      expect{ poly1.distance(nil) }.to raise_error(TypeError)
    end

    it 'should return distance to point' do
      expect(polygon1.distance([1/2r, 1/2r])).to eq(1/2r)
      expect(polygon1.distance([1, 1])).to eq(0)
      expect(polygon2.distance([1/2r, 1/2r])).to eq(3/4r)
      expect(polygon3.distance([1, 1])).to eq(Math.sqrt(2)/2)
    end

    it 'should return distance to polygon' do
      expect(polygon1.distance(polygon2)).to eq(1/4r)
      expect(polygon1.distance(polygon3)).to eq(Math.sqrt(2)/2)
      expect(polygon3.distance(polygon4)).to eq(2 * Math.sqrt(2)/5)
      expect(polygon5.distance(described_class.new([10, 10], [14, 14], [10, 14]))).to eq((6 * Math.sqrt(2)).round(14))
      expect(polygon5.distance(described_class.new([1, 8], [5, 8], [8, 12], [1, 12]))).to eq(4)
    end
  end
end
