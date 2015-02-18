module AdvRemoteCoords
  require 'net/http'
  extend ActiveSupport::Concern
  included do
    def get_remote_coords
      begin
        uri = 'http://geocode-maps.yandex.ru/1.x/'
        location = %w(region district city street address).inject('') do |sum, type|
          loc = self.locations.find{ |l| l.location_type == type }
          loc.present? ? "#{sum} #{loc.title}" : sum
        end.strip

        url = URI(uri)
        url.query = URI.encode_www_form({ format: 'json', geocode: location, results: 1 })

        res = Net::HTTP.get_response(url)
        addr = JSON.parse(res.body)
        if (addr['response']['GeoObjectCollection']['metaDataProperty']['GeocoderResponseMetaData']['found'] != '0')
          coords = addr['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['Point']['pos']
          self.latitude = coords.split(' ')[1]
          self.longitude = coords.split(' ')[0]
          self.zoom = 16
          coords
        end
      rescue
        nil
      end
    end
  end
end
