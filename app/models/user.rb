class User < ApplicationRecord
  has_many :cocktails, foreign_key: "bartender_id", dependent: :destroy
  has_many :categories, through: :cocktails

  has_many :likes, foreign_key: "liker_id", dependent: :destroy
  has_many :liked_cocktails, :through => :likes, :class_name => "Cocktail"

  has_many :workplaces, foreign_key: "bartender_id", dependent: :destroy
  has_many :bars, through: :workplaces

  has_many :favorites, dependent: :destroy
  has_many :favorited_bars, through: :favorites, class_name: "Bar"

  # users that I follow
  has_many :following_users, foreign_key: :followee_id, class_name: "Follow", dependent: :destroy
  has_many :followees, through: :following_users

  # users that follow me
  has_many :followed_users, foreign_key: :follower_id, class_name: "Follow", dependent: :destroy
  has_many :followers, through: :followed_users

  has_secure_password
  validates :username, uniqueness: { case_sensitive: false }, presence: true

  has_one_attached :avatar

  def instagram_info
    if self.instagram_account
      insta_api_url = "https://instagram28.p.rapidapi.com/user_info?user_name=#{self.instagram_account}"
      response = Faraday.get(insta_api_url, { "x-rapidapi-host" => "instagram28.p.rapidapi.com" }, { "x-rapidapi-key" => ENV["INSTA_KEY"] })
      res = JSON.parse(response.body)
      # res["candidates"][0]["place_id"]
    end
  end
end
