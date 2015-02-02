module AdvDoublefinder

  extend ActiveSupport::Concern

  included do
    def self.check_existence adv_params
      nearest_location = adv_params[:locations][:address] || adv_params[:locations][:street] ||
          adv_params[:locations][:village] || adv_params[:locations][:district] || adv_params[:locations][:region]
      #print " nearest_location #{nearest_location} \n"
      #first we find all advs in granted locations with our property_avd
      offer_type = Advertisement::OFFER_TYPES.index(adv_params[:offer_type].to_sym)
      category = Advertisement::CATEGORIES.index(adv_params[:category].to_sym)
      property_type = Advertisement::PROPERTY_TYPES.index(adv_params[:property_type].to_sym)
      #print "\n Chex category=#{category} offer_type=#{offer_type} property_type=#{property_type}\n"
      pre_advs = Advertisement.joins(:locations).where('locations.title = ? AND advertisements.offer_type = ?
                                  AND advertisements.category = ? AND user_id = ? AND advertisements.property_type = ?
                                  AND advertisements.price_from = ?',
                                                       nearest_location.title, offer_type, category, adv_params[:user_id], property_type, adv_params[:price].to_i)
      #print "\npre advs #{pre_advs.present?}\n"
      if pre_advs.blank?
        return false
      else
        #pre_advs = pre_advs.where('comment like ?', adv_params[:comment])
        #if pre_advs.present?
        #print "sorry, we found simular advertisement(s) #{pre_advs.map(&:id).join(';')}"
        return pre_advs
        #else
        #  return false
        #end
      end
    end
  end
end