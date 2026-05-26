# frozen_string_literal: true

class Bar < ApplicationRecord
  has_many :workplaces, dependent: :destroy
  has_many :bartenders, through: :workplaces, source: :users

  has_many :favorites, foreign_key: 'favorited_bar_id'
  has_many :users, through: :favorites
end
