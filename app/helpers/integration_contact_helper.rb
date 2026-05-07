module IntegrationContactHelper
  def format_phone_number_to_e164(phone_number)
    digits = phone_number.to_s.gsub(/\D/, '')
    digits = "55#{digits}" unless digits.start_with?('55')

    # Brazilian mobile numbers received a mandatory leading 9 in 2012. Some
    # upstream integrations still deliver the legacy 12-digit format; insert
    # the 9 so we always store the canonical 13-digit form. Landlines (local
    # prefix 2-5) keep the 12-digit form.
    if digits.length == 12 && digits[4].to_i.between?(6, 9)
      digits = "55#{digits[2, 2]}9#{digits[4..]}"
    end

    "+#{digits}"
  end

  def build_custom_attributes(order_data, corrupted_data = nil)
    attributes = {
      shipping_address: create_address_line(order_data['shippingAddress'])
    }

    if corrupted_data
      attributes.merge!(
        contact_corrupted: corrupted_data[:corrupted_contact],
        corrupted_value: corrupted_data[:corrupted_value],
        corrupted_type: corrupted_data[:corrupted_type]
      )
    end

    attributes
  end

  def create_address_line(address)
    address_line = "#{address['street']}, #{address['number']}, #{address['neighborhood']}" \
                   ", #{address['city']}-#{address['state']}, #{address['zipCode']}"
    address_line += ", #{address['complement']}" unless address['complement'].to_s.strip.empty?
    address_line
  end

  def add_attributes(contact, hash_attribue)
    (contact&.custom_attributes || {}).deep_merge(hash_attribue.stringify_keys)
  end
end
