# frozen_string_literal: true

require 'active_model'

module ActiveModel
  class ModelNotFound < StandardError
    def initialize(message = nil, model = nil, primary_key = nil, id = nil) # rubocop:disable Metrics/ParameterLists
      @primary_key = primary_key
      @model = model
      @id = id

      super(message)
    end
  end

  # = Active Model Relation
  class Relation # rubocop:disable Metrics/ClassLength
    include Enumerable

    autoload :Model, 'active_model/relation/model'
    autoload :Querying, 'active_model/relation/querying'
    autoload :Scoping, 'active_model/relation/scoping'
    autoload :WhereClause, 'active_model/relation/where_clause'
    autoload :WhereChain, 'active_model/relation/where_chain'
    autoload :OrderClause, 'active_model/relation/order_clause'

    attr_reader :model
    attr_accessor :offset_value, :limit_value, :where_clause, :order_clause, :extending_values

    delegate :each, :size, :last, to: :records

    def initialize(model, records = model.try(:records) || [])
      @model = model
      @records = records
      @where_clause = WhereClause.new
      @order_clause = OrderClause.new
      @offset_value = nil
      @limit_value = nil
      @extending_values = []
    end

    def find(id)
      primary_key = model.try(:primary_key) || :id

      find_by(primary_key => id) ||
        raise(ModelNotFound.new("Couldn't find #{model} with '#{primary_key}'=#{id}", model, primary_key, id))
    end

    def find_by(attributes = {})
      where_clause = self.where_clause + WhereClause.from_hash(attributes)

      records.find(&where_clause)
    end

    def where(...)
      spawn.where!(...)
    end

    def where!(attributes = {}, &)
      return WhereChain.new(spawn) unless attributes.any? || block_given?

      self.where_clause += WhereClause.build(attributes, &)
      self
    end

    def offset(...)
      spawn.offset!(...)
    end

    def offset!(offset)
      self.offset_value = offset
      self
    end

    def limit(...)
      spawn.limit!(...)
    end

    def limit!(limit)
      self.limit_value = limit
      self
    end

    def order(...)
      spawn.order!(...)
    end

    def order!(*values)
      self.order_clause += OrderClause.build(values)
      self
    end

    def extending(...)
      spawn.extending!(...)
    end

    def extending!(*modules, &)
      modules << Module.new(&) if block_given?
      modules.flatten!

      self.extending_values += modules

      extend(*extending_values) if extending_values.any?

      self
    end

    def all
      spawn
    end

    def to_ary
      records.dup
    end
    alias to_a to_ary

    def records
      @records
        .select(&where_clause)
        .sort(&order_clause)
        .drop(offset_value || 0)
        .take(limit_value || @records.size)
    end

    def scoping
      previous_scope = model.current_scope
      model.current_scope = self
      yield
    ensure
      model.current_scope = previous_scope
    end

    def inspect
      entries = records.take(11).map!(&:inspect)
      entries[10] = '...' if entries.size == 11

      "#<#{self.class.name} [#{entries.join(', ')}]>"
    end

    def except(*skips)
      relation_with(values.except(*skips))
    end

    def only(*keeps)
      relation_with(values.slice(*keeps))
    end

    private

    def method_missing(...)
      if model.respond_to?(...)
        scoping { model.public_send(...) }
      else
        super
      end
    end

    def respond_to_missing?(...)
      super || model.respond_to?(...)
    end

    def spawn
      clone
    end

    def values
      {
        where: where_clause,
        offset: offset_value,
        limit: limit_value
      }
    end

    def relation_with(values)
      spawn.tap do |relation|
        relation.where_clause = values[:where] || WhereClause.new
        relation.offset_value = values[:offset]
        relation.limit_value = values[:limit]
      end
    end
  end
end
