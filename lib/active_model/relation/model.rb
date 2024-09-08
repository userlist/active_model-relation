# frozen_string_literal: true

module ActiveModel
  class Relation
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Relation::Scoping
      include ActiveModel::Relation::Querying
    end
  end
end
