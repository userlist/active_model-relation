# frozen_string_literal: true

require 'active_model'

module ActiveModel
  # = Active Model Relation
  class Relation
    include Enumerable

    attr_reader :model

    delegate :each, :size, :last, to: :records

    autoload :Model, 'active_model/relation/model'
    autoload :Querying, 'active_model/relation/querying'
    autoload :Scoping, 'active_model/relation/scoping'

    def initialize(model, records = [])
      @model = model
      @records = records
      @where_clause = {}
    end

    def find(value)
      primary_key = model.try(:primary_key) || :id

      records.find { |record| record.public_send(primary_key) == value }
    end

    def find_by(...)
      where(...).first
    end

    def where(...)
      spawn.where!(...)
    end

    def where!(attributes)
      @where_clause.merge!(attributes)

      self
    end

    def offset(...)
      spawn.offset!(...)
    end

    def offset!(offset)
      @offset = offset

      self
    end

    def limit(...)
      spawn.limit!(...)
    end

    def limit!(limit)
      @limit = limit

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
        .select { |record| @where_clause.all? { |key, value| record.public_send(key) == value } }
        .drop(@offset || 0)
        .take(@limit || @records.size)
    end

    def scoping
      previous_scope = model.current_scope
      model.current_scope = self
      yield
    ensure
      model.current_scope = previous_scope
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
  end
end
