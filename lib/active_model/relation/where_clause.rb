module ActiveModel
  class Relation
    class WhereClause
      attr_reader :predicates

      class EqualsPredicate
        attr_reader :attribute, :value

        def initialize(attribute, value)
          @attribute = attribute
          @value = value
        end

        def call(record)
          record.public_send(attribute) == value
        end
      end

      def self.from_hash(attributes = {})
        new(attributes.map { |attribute, value| EqualsPredicate.new(attribute, value) })
      end

      def self.from_block(block)
        new(block)
      end

      def initialize(*predicates)
        @predicates = predicates.flatten(1)
      end

      def +(other)
        WhereClause.new(predicates + other.predicates)
      end

      def call(record)
        predicates.all? { |predicate| predicate.call(record) }
      end

      def to_proc
        ->(record) { call(record) }
      end
    end
  end
end
