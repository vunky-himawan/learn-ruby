module Utils
  class StringUtils
    def self.remove_underscores(str, replace_with: " ")
      raise ArgumentError, "Input must be a string" unless str.is_a?(String)
      str.gsub("_", replace_with)
    end
  end
end
