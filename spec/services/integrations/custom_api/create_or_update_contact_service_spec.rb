require 'rails_helper'

RSpec.describe Integrations::CustomApi::CreateOrUpdateContactService do
  let(:account) { create(:account) }
  let(:custom_api) { { 'account_id' => account.id, 'name' => 'Quickshop' } }

  let(:account_data_with_9) do
    {
      'id' => 'QS-1001',
      'firstName' => 'Lais',
      'lastName' => 'Porto',
      'email' => 'lais@example.com',
      'document' => '00000000000',
      'phoneNumber' => '5581981132326'
    }
  end

  let(:account_data_without_9) do
    account_data_with_9.merge('phoneNumber' => '558181132326')
  end

  let(:order_data) { { 'account' => account_data_with_9 } }

  describe '#perform' do
    context 'Path A — Quickshop creates contact, second Quickshop call uses 12-digit form' do
      it 'reuses the existing 13-digit canonical contact' do
        existing = create(:contact, account: account, phone_number: '+5581981132326',
                                     additional_attributes: { 'integration' => 'Quickshop',
                                                              'id_from_integration' => 'QS-1001' })

        expect do
          described_class.new(nil, custom_api, account_data_without_9).perform
        end.not_to change(Contact, :count)

        existing.reload
        expect(existing.phone_number).to eq('+5581981132326')
      end
    end

    context 'Path B — WhatsApp created contact first, Quickshop arrives later with different format' do
      it 'updates the existing 12-digit WhatsApp contact instead of creating a duplicate' do
        wa_contact = create(:contact, account: account, phone_number: '+558181132326', email: nil, identifier: nil)

        expect do
          described_class.new(nil, custom_api, account_data_with_9).perform
        end.not_to change(Contact, :count)

        wa_contact.reload
        expect(wa_contact.phone_number).to eq('+5581981132326')
        expect(wa_contact.identifier).to eq('00000000000')
        expect(wa_contact.additional_attributes['id_from_integration']).to eq('QS-1001')
      end

      it 'updates the existing 13-digit WhatsApp contact when Quickshop sends 12-digit form' do
        wa_contact = create(:contact, account: account, phone_number: '+5581981132326', email: nil, identifier: nil)

        expect do
          described_class.new(nil, custom_api, account_data_without_9).perform
        end.not_to change(Contact, :count)

        wa_contact.reload
        expect(wa_contact.identifier).to eq('00000000000')
      end
    end

    context 'when no existing contact matches' do
      it 'creates a new contact with the canonical 13-digit phone' do
        expect do
          described_class.new(order_data, custom_api, nil).perform
        end.to change(Contact, :count).by(1)

        contact = Contact.last
        expect(contact.phone_number).to eq('+5581981132326')
        expect(contact.email).to eq('lais@example.com')
        expect(contact.identifier).to eq('00000000000')
      end
    end

    context 'when phone matches a contact owned by a different Quickshop integration id' do
      it 'classifies the existing contact as phone-corrupted using variant matching' do
        create(:contact, account: account, phone_number: '+558181132326',
                         additional_attributes: { 'integration' => 'Quickshop',
                                                  'id_from_integration' => 'QS-OTHER' })

        expect do
          described_class.new(nil, custom_api, account_data_with_9).perform
        end.to change(Contact, :count).by(1)

        new_contact = Contact.where("additional_attributes->>'id_from_integration' = ?", 'QS-1001').first
        expect(new_contact.custom_attributes['corrupted_type']).to eq('phone')
      end
    end
  end
end
