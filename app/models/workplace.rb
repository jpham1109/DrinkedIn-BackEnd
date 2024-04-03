# frozen_string_literal: true

class Workplace < ApplicationRecord
  belongs_to :bar
  belongs_to :bartender, class_name: 'User'

  validates :bar_id, uniqueness: { scope: :bartender_id, message: 'already exist' }
end
