# frozen_string_literal: true

require 'active_model'

module ActiveModel
  class ModelNotFound < StandardError; end

  # = Active Model Relation
  class Relation
    include Enumerable

    autoload :Model, 'active_model/relation/model'
    autoload :Querying, 'active_model/relation/querying'
    autoload :Scoping, 'active_model/relation/scoping'

    attr_reader :model
    attr_accessor :offset_value, :limit_value, :where_clause, :extending_values

    delegate :each, :size, :last, to: :records

    def initialize(model, records = [])
      @model = model
      @records = records
      @where_clause = {}
      @offset_value = nil
      @limit_value = nil
      @extending_values = []
    end

    def find(value)
      primary_key = model.try(:primary_key) || :id

      model = records.find { |record| record.public_send(primary_key) == value }
      model || raise_model_not_found_error
    end

    def find_by(...)
      where(...).first
    end

    def where(...)
      spawn.where!(...)
    end

    def where!(attributes)
      where_clause.merge!(attributes)
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

    def all
      spawn
    end

    def to_ary
      records.dup
    end

    def records
      @records
        .select { |record| where_clause.all? { |key, value| record.public_send(key) == value } }
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

    def raise_model_not_found_error
      raise ModelNotFound
    end
  end
end
