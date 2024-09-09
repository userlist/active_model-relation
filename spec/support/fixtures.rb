# frozen_string_literal: true

class Project
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Relation::Model

  attribute :id, :integer
  attribute :state, :string, default: :draft
  attribute :priority, :integer, default: 1

  def self.completed
    where(state: 'completed')
  end
end
