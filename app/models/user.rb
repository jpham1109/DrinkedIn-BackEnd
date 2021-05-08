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

    has_one_attached :avatar

    def instagram_info
        if self.instagram_account
            insta_api_url= "https://instagram28.p.rapidapi.com/user_info?user_name=#{self.instagram_account}"
            response = Faraday.get(insta_api_url, {"x-rapidapi-host" => "instagram28.p.rapidapi.com"}, {"x-rapidapi-key" => ENV['INSTA_KEY']})
            res = JSON.parse(response.body)
            # res["candidates"][0]["place_id"]
        end
    end

    def workplace_id
        if self.work_at
            gm_place_search_url= "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{self.work_at}&inputtype=textquery&locationbias&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_place_search_url
            res = JSON.parse(response.body)
            res["candidates"][0]["place_id"]
        end
    end 

    def workplace_address
        if self.work_at
            gm_address_search_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=formatted_address&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_address_search_url
            res = JSON.parse(response.body)
            res["result"]["formatted_address"]
        end
    end
    
    def workplace_photoref_array
        if self.work_at
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=photos&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["photos"].map{|p| p["photo_reference"]}
        end
    end 

    def workplace_photo_array 
        workplace_photoref_array.map do |ref|
            gm_photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=#{ref}&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_photo_url
            response.headers["location"]
        end
    end 

    def workplace_reviews
        if self.work_at
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["reviews"]
        end
    end 


    def workplace_ratings_total 
        if self.work_at
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["user_ratings_total"]
        end
    end


    
    def workplace_rating 
        if self.work_at
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.workplace_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["rating"]
        end
    end

    # def instagram
    #     if self.instagram_account
    #         insta_info = self.instagram_info
    #         self.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url"] )
    #     end
    # end 
    
    # def workplace
    #     if self.work_at
    #         self.update(workplace_photos: self.workplace_photo_array, workplace_rating: self.workplace_rating, workplace_reviews: self.workplace_reviews, workplace_ratings_total: self.workplace_ratings_total)
    #     end
    # end

end
