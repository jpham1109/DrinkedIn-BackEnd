class User < ApplicationRecord
    has_many :cocktails, dependent: :destroy
    has_many :categories, through: :cocktails

    has_many :likes, dependent: :destroy
    has_many :liked_cocktails, through: :likes, class_name: 'Cocktail'

    has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
    has_many :followees, through: :followed_users

    has_many :following_users, foreign_key: :followee_id, class_name: 'Follow', dependent: :destroy
    has_many :followers, through: :following_users

    has_secure_password
    validates :username, uniqueness: { case_sensitive: false }

    def instagram_info
        insta_api_url= "https://instagram28.p.rapidapi.com/user_info?user_name=#{self.instagram_account}"
        response = Faraday.get(insta_api_url, {"x-rapidapi-host" => "instagram28.p.rapidapi.com"}, {"x-rapidapi-key" => ENV['INSTA_KEY']})
        res = JSON.parse(response.body)
        # res["candidates"][0]["place_id"]
    end

    def workplace_id
        gm_place_search_url= "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{self.work_at}&inputtype=textquery&locationbias&key=#{ENV['GM_KEY']}"
        response = Faraday.get gm_place_search_url
        res = JSON.parse(response.body)
        res["candidates"][0]["place_id"]
    end 

    def workplace_photoref_array
        gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=photos&key=#{ENV['GM_KEY']}"
        response = Faraday.get gm_detail_url
        res = JSON.parse(response.body)
        res["result"]["photos"].map{|p| p["photo_reference"]}
    end 

    def workplace_photo_array 
        workplace_photoref_array.map do |ref|
            gm_photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=#{ref}&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_photo_url
            response.headers["location"]
        end
    end 

    def workplace_reviews
        gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
        response = Faraday.get gm_detail_url
        res = JSON.parse(response.body)
        res["result"]["reviews"]
    end 

    def workplace_rating 
        gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
        response = Faraday.get gm_detail_url
        res = JSON.parse(response.body)
        res["result"]["rating"]
    end

    def workplace_ratings_total 
        gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
        response = Faraday.get gm_detail_url
        res = JSON.parse(response.body)
        res["result"]["user_ratings_total"]
    end
end
