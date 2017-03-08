module TinyTyping
  class << self
    def test?(*args)
      test!(*args)
      true
    rescue ArgumentError
      false
    end

    def test!(value, *types)
      check!(types, value)
    end

    private

    def check!(types, value)
      return if types.any? { |type| check?(type, value) }
      raise ArgumentError, "#{value.inspect} isn't #{types.map(&:inspect).join(' or ')}."
    end

    def check?(type, value)
      case type
      when Class
        value.is_a?(type)
      when true, false, nil
        value == type
      when Array
        return false unless value.is_a?(Array)
        value.each { |val| check!(type, val) }
        true
      when Hash
        return false unless value.is_a?(Hash)
        type.each { |key, val| check!(Array.try_convert(val) || [val], value[key]) }
        true
      else
        raise TypeError, "no implicit conversion of #{type.class} into Class"
      end
    end
  end
end

require 'tinytyping/version'
