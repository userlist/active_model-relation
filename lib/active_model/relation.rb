# frozen_string_literal: true

require 'active_model'

module ActiveModel
  # = Active Model Relation
  class Relation
    include Enumerable

    attr_reader :model

    delegate :each, :size, :last, to: :records

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

    def to_ary
      records.dup
    end

    def records
      @records
        .select { |record| @where_clause.all? { |key, value| record.public_send(key) == value } }
        .drop(@offset || 0)
        .take(@limit || @records.size)
    end

    private

    def spawn
      clone
    end
  end
end
