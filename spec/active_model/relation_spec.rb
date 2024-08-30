# frozen_string_literal: true

require 'active_model/relation'

RSpec.describe ActiveModel::Relation do
  it 'has a version number' do
    expect(ActiveModel::Relation::VERSION).not_to be nil
  end
end
