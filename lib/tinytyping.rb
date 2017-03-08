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

  class Base
    class << self
      private

      def typed_def(method, *types, &block)
        define_method(method) do |*args|
          types.each_with_index do |type, index|
            test!(args[index], *(Array.try_convert(type) || [type]))
          end
          instance_exec(*args, &block)
        end
      end

      def typed_attr_writer(pairs)
        pairs.each do |key, types|
          typed_def "#{key}=", types do |value|
            instance_variable_set("@#{key}", value)
          end
        end
      end

      def typed_attr_accessor(pairs)
        attr_reader(*pairs.keys)
        typed_attr_writer(pairs)
      end
    end

    private

    def test!(*args)
      TinyTyping.test!(*args)
    end
  end
end

require 'tinytyping/version'
