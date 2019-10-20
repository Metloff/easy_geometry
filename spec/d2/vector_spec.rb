require 'spec_helper'

RSpec.describe EasyGeometry::D2::Vector do
  let(:p1) { described_class.new(0, 0) }
  let(:p2) { described_class.new(1, 1) }
  let(:p3) { described_class.new(3, 0) }
  let(:p4) { described_class.new(2, 2) }
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

  describe '#==' do
    it 'should return true' do
      expect(p1 == p1).to be true
      expect(p2 == p2).to be true
      expect(p3 == p3).to be true
      expect(p4 == p4).to be true
    end

    it 'should return false' do
      expect(p1 == p2).to be false
      expect(p2 == p3).to be false
      expect(p3 == p4).to be false
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
      expect(p3 - p2).to eq(described_class.new(2, -1))
    end
  end

  describe '#orthogonal_direction' do
    it 'should return orthogonal vector' do
      expect(p1.orthogonal_direction).to eq(described_class.new(1, 0))
      expect(p2.orthogonal_direction).to eq(described_class.new(-1, 1))
    end
  end

  describe '#cross_product' do
    it 'should raise error if incorrect parameters' do
      expect { p1.cross_product(1) }.to raise_error(TypeError)
      expect { p1.cross_product('') }.to raise_error(TypeError)
      expect { p1.cross_product(nil) }.to raise_error(TypeError)
      expect { p1.cross_product(l1) }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1.cross_product(p2)).to eq(0)
      expect(p2.cross_product(p3)).to eq(-3)
      expect(p3.cross_product(p2)).to eq(3)
    end
  end

  describe '#dot' do
    it 'should raise error if incorrect parameters' do
      expect { p1.dot(1) }.to raise_error(TypeError)
      expect { p1.dot('') }.to raise_error(TypeError)
      expect { p1.dot(nil) }.to raise_error(TypeError)
      expect { p1.dot(l1) }.to raise_error(TypeError)
    end

    it 'should be equal' do
      expect(p1.dot(p2)).to eq(0)
      expect(p2.dot(p3)).to eq(3)
      expect(p3.dot(p2)).to eq(3)
      expect(p4.dot(p2)).to eq(4)
    end
  end
end