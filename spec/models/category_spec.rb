require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'name uniqueness' do
    it 'is valid with a unique name' do
      create(:category, name: 'Tiki')
      expect(build(:category, name: 'Highball')).to be_valid
    end

    it 'is invalid with an exact duplicate name' do
      create(:category, name: 'Tiki')
      duplicate = build(:category, name: 'Tiki')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end

    it 'is invalid with a case-insensitive duplicate name' do
      create(:category, name: 'Tiki')
      duplicate = build(:category, name: 'TIKI')
      expect(duplicate).not_to be_valid
    end

    it 'enforces the same rule at the database level via a unique index' do
      create(:category, name: 'Tiki')
      duplicate = build(:category, name: 'tiki')
      expect do
        duplicate.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
