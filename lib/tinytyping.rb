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
      nil
    end

    private

    def check!(types, value)
      index = types.index { |type| check?(type, value) }
      raise ArgumentError, "#{value.inspect} isn't #{types.map(&:inspect).join(' or ')}." unless index
      types[index]
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
        class_key_types = []
        named_key_types = []
        type.each_key do |key|
          if [Class, Array, Hash].any? { |klass| key.is_a?(klass) }
            class_key_types << key
          else
            named_key_types << key
          end
        end
        (value.keys + named_key_types).uniq.each do |key|
          ktype = type.include?(key) ? key : check!(class_key_types, key)
          vtype = type[ktype]
          check!(Array.try_convert(vtype) || [vtype], value[key])
        end
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
