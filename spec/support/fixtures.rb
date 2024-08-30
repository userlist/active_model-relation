class Project
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Relation::Model

  attribute :id, :integer
  attribute :state, :string, default: :draft

  def self.completed
    where(state: 'completed')
  end
end
