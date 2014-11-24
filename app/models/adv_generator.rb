module AdvGenerator

  extend ActiveSupport::Concern


  included do
    before_save :generate_attributes

    private

    def sorted_child_location(list, total_list, return_list=[])
      list.each do |m|
        return_list << m
        sorted_child_location(
            total_list.find_all{ |n| n.location_id == m.id}.sort_by{|l| Location.locations_list.index(l.location_type.to_s)},
            total_list,
            return_list)
      end
      return return_list
    end


    def generate_attributes

      self.user_role ||= self.user.role
      self.phone ||= self.user.phones.map{ |p| p.original }.join(', ')
      self.name ||= self.user.name

      child_location = []
      self.locations.each do |m|
        child_location << m if self.locations.find{|n| m.location_id == n.id}.blank?
      end

      locations_title = sorted_child_location(child_location, self.locations).delete_if do |l|
        not [:district, :city, :non_admin_area, :street, :address].include?(l.location_type.to_sym)
      end.map(&:title).join(' ')


      self.locations_title = locations_title unless self.locations_title.present?

      self.anchor = [
          AdvGenerator.enum_title(self.offer_type),
          AdvGenerator.enum_text(self, :room, 'к'), #без пробела
          AdvGenerator.enum_title(self.category),
          AdvGenerator.enum_text(self, :space, ' м²'),
          AdvGenerator.enum_text(self, :floor, ' этаж'),
          AdvGenerator.enum_text(self, :floor_cnt, ' этажей')
      ].delete_if{|e| e.to_s.strip == ''}.join(' ') unless self.anchor.present?

      self.title = [
          self.anchor,
          AdvGenerator.enum_text(self, :price, 'руб'),
      ].delete_if{|e| e.to_s.strip == ''}.join(' ') unless self.title.present?

      self.description = [
          Russian::strftime((self.updated_at || DateTime.now).to_date),
          AdvGenerator.enum_text(self, :price, 'руб'),
          "объявление #{self.id} в базе недвижимости"
      ].delete_if{|e| e.to_s.strip == ''}.join(' ') unless self.description.present?

      self.p = self.comment unless self.p.present?
      self.h1 = self.anchor unless self.h1.present?
      self.h2 = '' unless self.h2.present?
      self.h3 = '' unless self.h3.present?
      self.keywords = [
          AdvGenerator.enum_title(self.offer_type),
          AdvGenerator.enum_text(self, :room, 'ком.'),
          AdvGenerator.enum_title(self.category),
          AdvGenerator.enum_text(self, :space, 'м. кв.'),
          AdvGenerator.enum_text(self, :outdoors_space, 'сот'),
          self.locations_title,
          AdvGenerator.enum_text(self, :price, 'руб')
      ].delete_if{|e| e.to_s.strip == ''}.join(', ') unless self.keywords.present?

      self.url = self.title.to_s.parameterize unless self.url.present?

      first_photo = self.photos.first
      if first_photo.present?
        self.preview_url = first_photo.advertisement_photo(:thumb)
        self.preview_alt = first_photo.comment
      end
    end
  end

  def self.enum_text(adv, attr, units, prefix = nil)
    value_from = adv.send("#{attr}_from".to_sym)
    value_to = adv.send("#{attr}_to".to_sym)
    if value_from.present? && value_to.present? && value_from != value_to
      "#{prefix}от #{value_from} до #{value_to}#{units}"
    elsif value_from.present?
      "#{prefix}#{value_from}#{units}"
    else
      nil
    end
  end


  def self.enum_title(type)
    I18n.t("activerecord.attributes.advertisement.enum_title.#{type}")
  end

end
