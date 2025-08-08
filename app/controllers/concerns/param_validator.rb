module ParamValidator
  extend ActiveSupport::Concern

  def missing_params(required_params)
    required_params.select { |param| params[param].blank? }
  end

  def validate_required_params(required_params)
    missing = missing_params(required_params)
    if missing.any?
      bad_request("Missing required parameters: #{missing.join(', ')}")
      return false
    end
    true
  end
end
