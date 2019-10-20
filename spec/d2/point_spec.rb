require 'spec_helper'

RSpec.describe EasyGeometry::D2::Point do
  let(:p1) { described_class.new(0, 0) }
  let(:p2) { described_class.new(1, 1) }
  let(:p3) { described_class.new(3, 0) }
  let(:p4) { described_class.new(2, 2) }
  let(:p5) { described_class.new(-2, 2) }
  let(:l1) { EasyGeometry::D2::Line.new(p1, p2) }

  describe '.new' do
    it 'should raise error if incorrect parameters' do
      expect { described_class.new("1", 0) }.to raise_error(TypeError)
      expect { described_class.new(nil, 0) }.to raise_error(TypeError)
      expect { described_class.new({}, 0) }.to raise_error(TypeError)
    end

    it 'should convert coords to big decimal' do
      expect(p2.x).to be_kind_of(Rational)
      expect(p2.y).to be_kind_of(Rational)
    end
  end

  describe '.project' do
    it 'should raise error if incorrect parameters' do
      expect { described_class.project(1, 0) }.to raise_error(TypeError)
      expect { described_class.project(nil, "qwe") }.to raise_error(TypeError)
      expect { described_class.project(p2, p1) }.to raise_error(ArgumentError)
    end

    it 'should be equal' do
      expect(described_class.project(p2, p2)).to eq(p2)
      expect(described_class.project(p2, p3)).to eq(described_class.new(1, 0))
      expect(described_class.project(p3, p2)).to eq(described_class.new(1.5, 1.5))
    end
  end

  describe '.is_collinear?' do
    it 'should raise error if incorrect parameters' do
      expect { described_class.is_collinear?(1, 2) }.to raise_error(TypeError)
    end

    it 'should return true' do
      expect(described_class.is_collinear?()).to be true
      expect(described_class.is_collinear?(p1)).to be true
      expect(described_class.is_collinear?(p1, p2)).to be true
      expect(described_class.is_collinear?(p1, p2, p2, p2)).to be true
      expect(described_class.is_collinear?(p1, p2, p4)).to be true
    end

    it 'should return false' do
      expect(described_class.is_collinear?(p1, p2, p3, p4)).to be false
      expect(described_class.is_collinear?(p1, p2, p3)).to be false
    end
  end

  describe '.affine_rank' do
    it 'should raise error if incorrect parameters' do
      expect { described_class.affine_rank(1, 2) }.to raise_error(TypeError)
    end

    it 'should return -1' do
      expect(described_class.affine_rank()).to eq(-1)
    end
    # Other tests are meaningless because they test the Matrix class
  end

  describe '#dot' do
    it 'should raise error if incorrect parameters' do
      expect { p1.dot(1) }.to raise_error(TypeError)
      expect { p1.dot("sd") }.to raise_error(TypeError)
      expect { p1.dot(l1) }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1.dot(p2)).to eq(0)
      expect(p2.dot(p4)).to eq(4)
      expect(p2.dot(p5)).to eq(0)
    end
  end

  describe '#zero?' do
    it 'should return true' do
      expect(p1.zero?).to be true      
    end

    it 'should return false' do
      expect(p2.zero?).to be false
      expect(p3.zero?).to be false
      expect(p5.zero?).to be false
    end
  end

  describe '#==' do
    it 'should return true' do
      expect(p1 == p1).to be true
      expect(p2 == p2).to be true
      expect(p3 == p3).to be true
      expect(p4 == p4).to be true
      expect(p5 == p5).to be true
    end

    it 'should return false' do
      expect(p1 == p2).to be false
      expect(p3 == p2).to be false
      expect(p4 == p1).to be false
      expect(p1 == 2).to be false
      expect(p1 == '').to be false
      expect(p1 == {}).to be false
    end
  end

  describe '#-' do
    it 'should raise error if incorrect parameters' do
      expect { p1 - 1 }.to raise_error(TypeError)
      expect { p2 - '' }.to raise_error(TypeError)
      expect { p2 - l1 }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1 - p2).to eq(described_class.new(-1, -1))
      expect(p5 - p3).to eq(described_class.new(-5, 2))
      expect(p5 - p5).to eq(described_class.new(0, 0))
    end
  end

  describe '#+' do
    it 'should raise error if incorrect parameters' do
      expect { p1 + 1 }.to raise_error(TypeError)
      expect { p2 + '' }.to raise_error(TypeError)
      expect { p2 + l1 }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1 + p2).to eq(described_class.new(1, 1))
      expect(p5 + p3).to eq(described_class.new(1, 2))
      expect(p5 + p5).to eq(described_class.new(-4, 4))
    end
  end

  describe '#*' do
    it 'should raise error if incorrect parameters' do
      expect { p1 * p1 }.to raise_error(TypeError)
      expect { p2 * '' }.to raise_error(TypeError)
      expect { p1 * l1 }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1 * 10).to eq(described_class.new(0, 0))
      expect(p2 * 10).to eq(described_class.new(10, 10))
      expect(p5 * -2).to eq(described_class.new(4, -4))
    end
  end

  describe '#/' do
    it 'should raise error if incorrect parameters' do
      expect { p1 / p1 }.to raise_error(TypeError)
      expect { p2 / '' }.to raise_error(TypeError)
      expect { p1 / l1 }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1 / 10).to eq(described_class.new(0, 0))
      expect(p2 / 10).to eq(described_class.new(0.1, 0.1))
      expect(p5 / -2).to eq(described_class.new(1, -1))
    end
  end

  describe '#distance' do
    it 'should raise error if incorrect parameters' do
      expect { p1.distance(1) }.to raise_error(TypeError)
      expect { p1.distance('') }.to raise_error(TypeError)
      expect { p1.distance(nil) }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1.distance(p2)).to eq(Math.sqrt(2))
      expect(p1.distance(p4)).to eq(Math.sqrt(8))
      expect(p3.distance(p5)).to eq(Math.sqrt(29))
    end
  end

  describe '#intersection' do
    it 'should raise error if incorrect parameters' do
      expect { p1.intersection(1) }.to raise_error(TypeError)
      expect { p1.intersection('') }.to raise_error(TypeError)
      expect { p1.intersection(nil) }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1.intersection(described_class.new(0, 0))).to eq([p1])
      expect(p1.intersection(p2)).to eq([])
    end
  end

  describe '#midpoint' do
    it 'should raise error if incorrect parameters' do
      expect { p1.midpoint(1) }.to raise_error(TypeError)
      expect { p1.midpoint('') }.to raise_error(TypeError)
      expect { p1.midpoint(nil) }.to raise_error(TypeError)
      expect { p1.midpoint(l1) }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1.midpoint(p1)).to eq(p1)
      expect(p1.midpoint(p2)).to eq(described_class.new(0.5, 0.5))
      expect(p1.midpoint(p3)).to eq(described_class.new(1.5, 0))
      expect(p2.midpoint(p5)).to eq(described_class.new(-0.5, 1.5))
    end
  end
end
