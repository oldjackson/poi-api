require 'rest-client'
require 'json'

MAP_BOX_API_URL = "https://api.mapbox.com/geocoding/v5/mapbox.places"
# max number of items returned by Mapbox search
MAX_ITEMS = 10

module Api
  module V1
    class PoisController < ApplicationController
      def museums
        pois("museum")
      end

      ### Simply add more analogous actions for other POI categories
      # def restaurants
      #   pois("restaurant")
      # end

      # def cinemas
      #   pois("cinema")
      # end

      # ...

      ###

      private

      def pois(category)
        begin
          response = RestClient.get map_box_url(category)
          render json: pois_by_postcode_json(response)
        rescue RestClient::Exception => e
          # to return also proper error messages from Mapbox
          render json: e.response.body
        end
      end

      def map_box_url(category)
        url = "#{MAP_BOX_API_URL}/#{category}.json?access_token=#{MB_CONFIG['map_box_api_token']}&limit=#{MAX_ITEMS}"
        lng = params[:lng]
        lat = params[:lat]

        # if both lng and lat parameter are passed, the proximity parameter is added to the url
        lng.nil? || lat.nil? ? url : url + "&proximity=#{lng}%2C#{lat}"

        # more Mapbox supported parameter can be added
        # params[:cnt].nil? ? url : url + "&country=#{cnt}"
      end

      def pois_by_postcode_json(response)
        response_hash = JSON.parse(response)

        pois_feats = response_hash["features"]

        # names_by_postcode has an empty array as default value when a new key is declared
        names_by_postcode = Hash.new([])

        pois_feats.each do |poi_props|
          # the postcode of feature poi_props, if present, is inside an element of the poi_props["context"] array ...
          # ... which is made of hashes having an 'id' key. If the corresponding value starts with 'postcode' the hash is extracted
          postcode_hash = poi_props["context"].find { |hsh| hsh["id"][(0..7)] == "postcode" }
          # ... and its 'text' value is the postcode; if not found, the postcode is saved as "unknown"
          postcode = postcode_hash.nil? ? "unknown" : postcode_hash["text"]
          # if the postcode had already been found, the feature name is added to the array whose key is the postcode...
          # ... otherwise the key is created with the corresponding value initialized with an empty array, which is then added with ...
          # ... a one-element array containing the name.
          names_by_postcode[postcode] += [poi_props["text"]]
        end

        JSON.generate(names_by_postcode)
      end
    end
  end
end
