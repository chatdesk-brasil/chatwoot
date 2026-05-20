require 'rails_helper'

RSpec.describe IntegrationContactHelper do
  let(:helper) { Class.new { include IntegrationContactHelper }.new }

  describe '#format_phone_number_to_e164' do
    context 'when input is a Brazilian mobile in legacy 12-digit format' do
      it 'inserts the leading 9 (DDD 81)' do
        expect(helper.format_phone_number_to_e164('558181132326')).to eq('+5581981132326')
      end

      it 'inserts the leading 9 (DDD 11)' do
        expect(helper.format_phone_number_to_e164('551188887777')).to eq('+5511988887777')
      end

      it 'works without country code prefix' do
        expect(helper.format_phone_number_to_e164('8181132326')).to eq('+5581981132326')
      end

      it 'strips formatting characters before evaluating length' do
        expect(helper.format_phone_number_to_e164('+55 (81) 8113-2326')).to eq('+5581981132326')
      end
    end

    context 'when input is a Brazilian mobile already in 13-digit format' do
      it 'returns the canonical E.164 number unchanged' do
        expect(helper.format_phone_number_to_e164('5581981132326')).to eq('+5581981132326')
      end

      it 'strips formatting and returns the canonical form' do
        expect(helper.format_phone_number_to_e164('+55 (81) 98113-2326')).to eq('+5581981132326')
      end
    end

    context 'when input is a Brazilian landline (12 digits, local prefix 2-5)' do
      it 'leaves landlines unchanged (no 9 inserted)' do
        # São Paulo landline (11) 3030-4040
        expect(helper.format_phone_number_to_e164('551130304040')).to eq('+551130304040')
      end

      it 'leaves landlines with local prefix 4 unchanged' do
        expect(helper.format_phone_number_to_e164('554140005000')).to eq('+554140005000')
      end
    end
  end
end
