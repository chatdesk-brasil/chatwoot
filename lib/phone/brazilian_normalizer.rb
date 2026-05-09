module Phone
  # Centralizes Brazilian phone number normalization logic.
  #
  # Brazilian mobile numbers received a mandatory leading 9 in 2012; integrations
  # and webhooks may deliver either the 12-digit legacy form or the 13-digit
  # canonical form. This module exposes both forms so callers can normalize
  # output (`canonical`) or expand a lookup to match either form (`variants`).
  #
  # The 9 is only inserted/stripped for numbers in the historical mobile prefix
  # range (local first digit 6-9). Landlines (local prefix 2-5) are left
  # unchanged, as are non-Brazilian numbers and unrecognized lengths.
  module BrazilianNormalizer
    module_function

    # Returns an array of E.164 strings: the canonical 13-digit BR mobile form
    # first, then the legacy 12-digit form. For non-mobile, non-Brazilian, or
    # unrecognized inputs returns a single-element array with the original
    # input untouched.
    def variants(phone_number)
      digits = phone_number.to_s.gsub(/\D/, '')
      return [phone_number] unless digits.start_with?('55')

      ddd = digits[2, 2]
      local = digits[4..].to_s

      case digits.length
      when 12
        return [phone_number] unless mobile_local_prefix?(local[0])

        ["+55#{ddd}9#{local}", "+55#{ddd}#{local}"]
      when 13
        return [phone_number] unless local[0] == '9'

        ["+55#{ddd}#{local}", "+55#{ddd}#{local[1..]}"]
      else
        [phone_number]
      end
    end

    # Returns the canonical 13-digit BR mobile form when the input is a BR
    # mobile, otherwise returns the input unchanged.
    def canonical(phone_number)
      variants(phone_number).first
    end

    # Returns true when both inputs refer to the same Brazilian mobile number
    # regardless of the 12-digit / 13-digit format. Falls back to strict
    # equality for non-Brazilian or unrecognized inputs. Symmetric on the
    # canonical form so argument order does not affect the result.
    def matches?(phone_a, phone_b)
      return false if phone_a.nil? || phone_b.nil?
      return true if phone_a == phone_b

      canonical(phone_a) == canonical(phone_b)
    end

    def mobile_local_prefix?(digit)
      return false if digit.nil?

      digit.to_i.between?(6, 9)
    end
  end
end
