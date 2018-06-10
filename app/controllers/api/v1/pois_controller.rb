require 'rest-client'
require 'json'

MAP_BOX_API_URL = "https://api.mapbox.com/geocoding/v5/mapbox.places"
MAX_ITEMS = 10

module Api
  module V1
    class PoisController < ApplicationController
      def museums
        pois("museum")
      end

      # def restaurants
      #   pois("restaurant")
      # end

      private

      def pois(category)
        response = RestClient.get map_box_url(category)

        render json: pois_by_postcode_json(response)
      end

      def map_box_url(category)
        url = "#{MAP_BOX_API_URL}/#{category}.json?access_token=#{MB_CONFIG['map_box_api_token']}&limit=#{MAX_ITEMS}"
        lng = params[:lng]
        lat = params[:lat]

        lng.nil? || lat.nil? ? url : url + "&proximity=#{lng}%2C#{lat}"
      end

      def pois_by_postcode_json(response)
        response_hash = JSON.parse(response)

        pois_feats = response_hash["features"]

        names_by_postcode = Hash.new([])

        pois_feats.each do |poi_props|
          postcode_hash = poi_props["context"].find { |hsh| hsh["id"][(0..7)] == "postcode" }
          postcode = postcode_hash.nil? ? "unknown" : postcode_hash["text"]
          names_by_postcode[postcode] += [poi_props["text"]]
        end

        JSON.generate(names_by_postcode)
      end
    end
  end
end
