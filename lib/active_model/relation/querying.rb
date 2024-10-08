# frozen_string_literal: true

module ActiveModel
  class Relation
    module Querying
      extend ActiveSupport::Concern

      module ClassMethods
        delegate :where, :find, :find_by, :offset, :limit, :first, :last, to: :all

        def all
          current_scope || ActiveModel::Relation.new(self)
        end
      end
    end
  end
end
