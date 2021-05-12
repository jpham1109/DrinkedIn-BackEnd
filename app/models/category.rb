class Category < ApplicationRecord
    has_many :cocktails
    # has_many :users, through: :cocktails
end
