module TinyTyping
  class Tester
    class << self
      def expect(types, value)
        index = types.index { |type| expect_shape(type, value) }
        raise ArgumentError, "#{value.inspect} isn't #{types.map(&:inspect).join(' or ')}." unless index
        types[index]
      end

      def expect_shape(type, value)
        case type
        when Class
          value.is_a?(type)
        when true, false, nil
          value == type
        when Array
          return false unless value.is_a?(Array)
          value.each { |val| expect(type, val) }
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
            ktype = type.include?(key) ? key : expect(class_key_types, key)
            vtype = type[ktype]
            expect(Array.try_convert(vtype) || [vtype], value[key])
          end
          true
        else
          raise TypeError, "no implicit conversion of #{type.class} into Class"
        end
      end
    end

    def initialize(*types)
      @types = types
    end

    def run!(value)
      self.class.expect(@types, value)
      nil
    end
  end

  class << self
    def test?(*args)
      test!(*args)
      true
    rescue ArgumentError
      false
    end

    def test!(value, *types)
      Tester.new(*types).run!(value)
    end

    private

    def included(base)
      base.class_eval do
        private

        def test!(*args)
          TinyTyping.test!(*args)
        end

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
      end
    end
  end

  class Base
    include TinyTyping
  end
end

require 'tinytyping/version'
