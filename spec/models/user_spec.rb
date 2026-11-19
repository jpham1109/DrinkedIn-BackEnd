# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'email' do
    it 'is valid with a unique email' do
      user = build(:user, email: 'person@example.com')
      expect(user).to be_valid
    end

    it 'is invalid with an exact duplicate email' do
      create(:user, email: 'person@example.com')
      user = build(:user, email: 'person@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with a case-insensitive duplicate email' do
      create(:user, email: 'Person@Example.com')
      user = build(:user, email: 'person@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is valid for multiple users with no email at all' do
      create(:user, email: nil)
      user = build(:user, email: nil)
      expect(user).to be_valid
    end

    it 'is invalid with a malformed email' do
      user = build(:user, email: 'not-an-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is valid when email is blank' do
      user = build(:user, email: '')
      expect(user).to be_valid
    end

    it 'normalizes a whitespace-only email to nil rather than a validation error' do
      user = build(:user, email: '   ')
      expect(user).to be_valid
      expect(user.email).to be_nil
    end

    it 'trims incidental surrounding whitespace, preserving casing' do
      user = build(:user, email: '  Person@Example.com  ')
      user.valid?
      expect(user.email).to eq('Person@Example.com')
    end

    it 'enforces the same uniqueness rule at the database level via a unique index' do
      create(:user, email: 'person@example.com')
      user = build(:user, email: 'person@example.com')
      expect do
        user.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
