module Validators
  module EmailValidator
    def self.validate(email)
      return false unless email.present?

      email_regex = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
      email.match?(email_regex) && email.length <= 255
    end
  end
end
