# frozen_string_literal: true

module ActiveModel
  class Relation
    class OrderClause
      class OrderExpression
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def call(record, other)
          record.public_send(name) <=> other.public_send(name)
        end
      end

      class Ascending < OrderExpression; end

      class Descending < OrderExpression
        def call(record, other)
          super(other, record)
        end
      end

      attr_reader :expressions

      def self.build(value = [])
        if value.is_a?(Array)
          from_array(value)
        elsif value.is_a?(Hash)
          from_hash(value)
        else
          from_value(value)
        end
      end

      def self.from_value(value)
        new(Ascending.new(value))
      end

      def self.from_array(attributes)
        expressions = attributes.map { |name| build(name) }

        new(expressions)
      end

      def self.from_hash(attributes)
        expressions = attributes.map do |name, direction|
          if direction == :asc
            Ascending.new(name)
          elsif direction == :desc
            Descending.new(name)
          else
            raise ArgumentError, "Invalid direction #{direction.inspect}. Direction should either be :asc or :desc."
          end
        end

        new(expressions)
      end

      def initialize(*expressions)
        @expressions = expressions.flatten(1)
      end

      def +(other)
        OrderClause.new(@expressions + other.expressions)
      end

      def call(record, other)
        return 0 if expressions.empty?

        expressions.each do |expression|
          result = expression.call(record, other)

          return result unless result.zero?
        end

        0
      end

      def to_proc
        method(:call).to_proc
      end
    end
  end
end
