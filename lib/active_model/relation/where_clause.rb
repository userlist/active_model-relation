# frozen_string_literal: true

module ActiveModel
  class Relation
    class WhereClause
      class Predicate
        def call(record)
          raise NotImplementedError
        end

        def invert
          NotPredicate.new(self)
        end
      end

      class EqualsPredicate < Predicate
        attr_reader :attribute, :value

        def initialize(attribute, value)
          super()

          @attribute = attribute
          @value = value
        end

        def call(record)
          record.public_send(attribute) == value
        end
      end

      class BlockPredicate < Predicate
        attr_reader :block

        def initialize(block)
          super()

          @block = block
        end

        def call(record)
          block.call(record)
        end
      end

      class NotPredicate < Predicate
        attr_reader :predicate

        def initialize(predicate)
          super()

          @predicate = predicate
        end

        def call(record)
          !predicate.call(record)
        end

        def invert
          predicate
        end
      end

      attr_reader :predicates

      def self.from_hash(attributes = {})
        new(attributes.map { |attribute, value| EqualsPredicate.new(attribute, value) })
      end

      def self.from_block(block)
        new(BlockPredicate.new(block))
      end

      def self.build(attributes = {}, &block)
        where_clause = new
        where_clause += from_hash(attributes) if attributes.any?
        where_clause += from_block(block) if block_given?
        where_clause
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

      def invert
        WhereClause.new(predicates.map(&:invert))
      end

      def to_proc
        method(:call).to_proc
      end
    end
  end
end
