class Bar < ApplicationRecord
    has_many :workplaces, dependent: :destroy
    has_many :bartenders, through: :workplaces, source: :users

    has_many :favorites, foreign_key: "favorited_bar_id"
    has_many :users, through: :favorites

    def place_id
        
            gm_place_search_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.7128,-74.0060&radius=15000&type=bar&keyword=#{self.name}&key=#{ENV['GM_KEY']}"

        #     gm_place_search_url= "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{self.name}&inputtype=textquery&locationbias&type=bar&key=#{ENV['GM_KEY']}"
            
            response = Faraday.get gm_place_search_url
            res = JSON.parse(response.body)
     
        #     res["candidates"][0]["place_id"]
            res["results"][0]["place_id"]
        
    end 

    def address
        
            gm_address_search_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.place_id}&fields=formatted_address&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_address_search_url
            res = JSON.parse(response.body)
            res["result"]["formatted_address"]
        
    end

    def website
        gm_website_search_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.place_id}&fields=website&key=#{ENV['GM_KEY']}"
        response = Faraday.get gm_website_search_url
        res = JSON.parse(response.body)
        res["result"]["website"]
    end 
    
    def photoref_array
        
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.place_id}&fields=photos&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["photos"].map{|p| p["photo_reference"]}
        
    end 

    def photo_array 
        photoref_array.map do |ref|
            gm_photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=#{ref}&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_photo_url
            response.headers["location"]
        end
    end 

    def reviews
        
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.place_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["reviews"]
       
    end 


    def total_ratings 
        
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.place_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["user_ratings_total"]
        
    end


    
    def rating 
       
            gm_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{self.place_id}&fields=reviews,rating,user_ratings_total&key=#{ENV['GM_KEY']}"
            response = Faraday.get gm_detail_url
            res = JSON.parse(response.body)
            res["result"]["rating"]
       
    end
end
