# frozen_string_literal: true

module TinyTyping
  class Tester
    class << self
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
            case key
            when Class, Array
              class_key_types << key
            else
              named_key_types << key
            end
          end
          (value.keys + named_key_types).uniq.each do |key|
            expect(class_key_types.flatten(1), key) unless type.include?(key)
            ktypes = []
            ktypes << key if named_key_types.include?(key)
            ktypes.push(*class_key_types.select { |t| expect_any(t, key) }) if value.include?(key)
            expect(ktypes.flat_map { |k| type[k] }, value[key])
          end
          true
        else
          raise TypeError, "no implicit conversion of #{type.class} into Class"
        end
      end

      def expect_any(types, value)
        (Array.try_convert(types) || [types]).any? { |type| expect_shape(type, value) }
      end

      def expect(types, value)
        return if expect_any(types, value)

        raise ArgumentError, "#{value.inspect} isn't #{(Array.try_convert(types) || [types]).map(&:inspect).join(' or ')}."
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
