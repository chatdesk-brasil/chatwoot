require 'rails_helper'

RSpec.describe Phone::BrazilianNormalizer do
  describe '.variants' do
    context 'with a 12-digit Brazilian mobile (legacy, no leading 9)' do
      it 'returns the canonical 13-digit form first and the legacy form second' do
        expect(described_class.variants('+558181132326')).to eq(['+5581981132326', '+558181132326'])
      end

      it 'works with DDD 11 mobile prefixes' do
        expect(described_class.variants('+551188887777')).to eq(['+5511988887777', '+551188887777'])
      end
    end

    context 'with a 13-digit Brazilian mobile (canonical, leading 9)' do
      it 'returns the canonical form first and the 12-digit legacy form second' do
        expect(described_class.variants('+5581981132326')).to eq(['+5581981132326', '+558181132326'])
      end
    end

    context 'with a Brazilian landline (12 digits, local prefix 2-5)' do
      it 'returns only the input unchanged' do
        expect(described_class.variants('+551130304040')).to eq(['+551130304040'])
      end
    end

    context 'with a non-Brazilian number' do
      it 'returns only the input unchanged' do
        expect(described_class.variants('+12025551234')).to eq(['+12025551234'])
      end
    end

    context 'with a blank or unrecognized input' do
      it 'returns the input unchanged when it has an unexpected length' do
        expect(described_class.variants('+5511')).to eq(['+5511'])
      end

      it 'handles nil safely by returning the original input' do
        expect(described_class.variants(nil)).to eq([nil])
      end
    end
  end

  describe '.canonical' do
    it 'returns the 13-digit canonical form for a legacy 12-digit BR mobile' do
      expect(described_class.canonical('+558181132326')).to eq('+5581981132326')
    end

    it 'returns the canonical form unchanged when already 13 digits' do
      expect(described_class.canonical('+5581981132326')).to eq('+5581981132326')
    end

    it 'leaves landlines unchanged' do
      expect(described_class.canonical('+551130304040')).to eq('+551130304040')
    end

    it 'leaves non-Brazilian numbers unchanged' do
      expect(described_class.canonical('+12025551234')).to eq('+12025551234')
    end
  end

  describe '.matches?' do
    it 'matches the same BR mobile across 12-digit and 13-digit forms' do
      expect(described_class.matches?('+558181132326', '+5581981132326')).to be true
      expect(described_class.matches?('+5581981132326', '+558181132326')).to be true
    end

    it 'returns true for identical inputs' do
      expect(described_class.matches?('+5581981132326', '+5581981132326')).to be true
    end

    it 'returns false for different BR mobile numbers' do
      expect(described_class.matches?('+5581981132326', '+5581988887777')).to be false
    end

    it 'is symmetric (argument order does not change the result)' do
      expect(described_class.matches?('+558181132326', '+5581981132326'))
        .to eq(described_class.matches?('+5581981132326', '+558181132326'))
    end

    it 'does not match a BR landline against a mobile that shares the same trailing 8 digits' do
      expect(described_class.matches?('+551130304040', '+5511930304040')).to be false
      expect(described_class.matches?('+5511930304040', '+551130304040')).to be false
    end

    it 'returns false for nil inputs' do
      expect(described_class.matches?(nil, '+5581981132326')).to be false
      expect(described_class.matches?('+5581981132326', nil)).to be false
      expect(described_class.matches?(nil, nil)).to be false
    end
  end
end
