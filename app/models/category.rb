# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :cocktails
  has_many :bartenders, through: :cocktails, class_name: 'User'
end
