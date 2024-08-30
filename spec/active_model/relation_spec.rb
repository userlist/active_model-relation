# frozen_string_literal: true

require 'active_model/relation'

class Project
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :state, :string, default: :draft
end

RSpec.describe ActiveModel::Relation do
  it 'has a version number' do
    expect(ActiveModel::Relation::VERSION).not_to be nil
  end

  let(:model_class) { Project }
  let(:records) do
    [
      model_class.new(id: 1, state: 'draft'),
      model_class.new(id: 2, state: 'running'),
      model_class.new(id: 3, state: 'completed')
    ]
  end

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
end
