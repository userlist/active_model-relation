# frozen_string_literal: true

require 'active_model/relation'
require 'active_model/relation/scoping'
require 'active_model/relation/querying'

class Project
  include ActiveModel::Model
  include ActiveModel::Attributes

  include ActiveModel::Relation::Scoping
  include ActiveModel::Relation::Querying

  attribute :id, :integer
  attribute :state, :string, default: :draft

  def self.records
    [
      new(id: 1, state: 'draft'),
      new(id: 2, state: 'running'),
      new(id: 3, state: 'completed')
    ]
  end

  def self.completed
    where(state: 'completed')
  end
end

RSpec.describe ActiveModel::Relation do
  it 'has a version number' do
    expect(ActiveModel::Relation::VERSION).not_to be nil
  end

  let(:model_class) { Project }
  let(:records) { Project.records }

  subject { described_class.new(model_class, records) }

  describe '#model' do
    it 'should return the model class' do
      expect(subject.model).to eq(model_class)
    end
  end

  describe '#find' do
    it 'should return the record by primary key' do
      expect(subject.find(1)).to eq(records[0])
    end
  end

  describe '#find_by' do
    it 'should return the record matching the given attributes' do
      expect(subject.find_by(state: 'running')).to eq(records[1])
    end
  end

  describe '#size' do
    it 'should return the number of records' do
      expect(subject.size).to eq(3)
    end

    context 'when the records are filtered' do
      it 'should return the number of filtered records' do
        expect(subject.where(state: 'completed').size).to eq(1)
      end
    end
  end

  describe '#where' do
    it 'should return a new relation' do
      expect(subject.where(state: 'completed')).to be_a(described_class)
    end

    it 'should return a new instance' do
      expect(subject.where(state: 'completed')).not_to eq(subject)
    end

    it 'should filter the records' do
      expect(subject.where(state: 'completed')).to match_array([records[2]])
    end
  end

  describe '#offset' do
    it 'should return a new relation' do
      expect(subject.offset(1)).to be_a(described_class)
    end

    it 'should return a new instance' do
      expect(subject.offset(1)).not_to eq(subject)
    end

    it 'should offset the records' do
      expect(subject.offset(1)).to match_array(records[1..2])
    end
  end

  describe '#limit' do
    it 'should return a new relation' do
      expect(subject.limit(1)).to be_a(described_class)
    end

    it 'should return a new instance' do
      expect(subject.limit(1)).not_to eq(subject)
    end

    it 'should limit the records' do
      expect(subject.limit(1)).to match_array(records[0..0])
    end
  end

  describe '#all' do
    it 'should return a new relation' do
      expect(subject.all).to be_a(described_class)
    end

    it 'should return a new instance' do
      expect(subject.all).not_to eq(subject)
    end

    it 'should return the same records' do
      expect(subject.all).to match_array(subject)
    end
  end

  describe 'model class methods' do
    it 'should delegate methods to the model class' do
      expect(subject.model_name).to eq(model_class.model_name)
    end

    it 'should apply the scope to the model class method' do
      expect(subject.completed).to match_array([records[2]])
    end
  end
end
