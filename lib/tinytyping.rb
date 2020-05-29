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

          def method_added(method)
            return unless @next_decorator

            unbound_method = instance_method(method)

            if unbound_method.arity == @next_decorator_airty && (@prev_added_method.nil? || method.to_s == "#{@prev_added_method}=")
              decorator = @next_decorator
              @next_decorator = @prev_added_method = nil
              define_method(method) do |*args, &block|
                decorator.call(unbound_method.bind(self), *args, &block)
              end
            elsif unbound_method.arity.zero? && @prev_added_method.nil?
              @prev_added_method = method
            else
              raise ArgumentError, "#{method}.arity(#{unbound_method.arity}) does not match decorator's arity(#{@next_decorator_airty})"
            end
          end

          def decorate(airty, &block)
            @next_decorator_airty = airty
            @next_decorator = block
            @prev_added_method = nil
          end

          def typed(*types)
            return if types.empty?

            decorate(types.size) do |method, *args, &block|
              types.each_with_index do |type, index|
                TinyTyping.test!(args[index], *(Array.try_convert(type) || [type]))
              end
              method.call(*args, &block)
            end
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
