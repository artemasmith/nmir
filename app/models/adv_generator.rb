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

      locations = sorted_child_location(child_location, self.locations).delete_if do |l|
        not [:district, :city, :non_admin_area, :street, :address].include?(l.location_type.to_sym)
      end

      locations_present =
          locations.find{|e| e.location_type.to_sym == :non_admin_area}.present? &&
          locations.find{|e| e.location_type.to_sym == :street}.present? &&
          locations.find{|e| e.location_type.to_sym == :address}.present?

      locations_title = (locations.delete_if do |l|
        l.location_type.to_sym == :district && locations_present
      end.map(&:title) + [self.landmark]).delete_if{|e| e.to_s.strip == ''}.join(' ')


      self.locations_title = locations_title

      self.anchor = [
          AdvGenerator.enum_title(self.offer_type),
          AdvGenerator.enum_text(self, :room, 'к'), #без пробела
          AdvGenerator.enum_title(self.category),
          AdvGenerator.enum_text(self, :space, ' м²'),
          AdvGenerator.enum_text(self, :outdoors_space, ' сот', 'на участке '),
          AdvGenerator.floor_and_flor_cnt_text(self),
      ].delete_if{|e| e.to_s.strip == ''}.join(' ')

      self.title = [
          self.anchor,
          AdvGenerator.enum_text(self, :price, ' руб', nil, true),
          locations_title
      ].delete_if{|e| e.to_s.strip == ''}.join(' ')

      self.description = [
          Russian::strftime((self.updated_at || DateTime.now).to_date),
          AdvGenerator.enum_text(self, :price, ' руб'),
          "объявление #{self.id} в базе недвижимости"
      ].delete_if{|e| e.to_s.strip == ''}.join(' ')

      self.p = self.comment
      self.h1 = [
          self.anchor,
          locations_title
      ].delete_if{|e| e.to_s.strip == ''}.join(' ')
      self.h2 = ''
      self.h3 = ''
      self.keywords = [
          AdvGenerator.enum_title(self.offer_type),
          AdvGenerator.enum_text(self, :room, 'к'),
          AdvGenerator.enum_title(self.category),
          AdvGenerator.enum_text(self, :space, 'м. кв.'),
          AdvGenerator.enum_text(self, :outdoors_space, ' сот', 'на участке '),
          self.locations_title,
          AdvGenerator.enum_text(self, :price, 'руб')
      ].delete_if{|e| e.to_s.strip == ''}.join(', ')

      self.url = self.title.to_s.parameterize unless self.url.present?

      first_photo = self.photos.first
      if first_photo.present?
        self.preview_url = first_photo.advertisement_photo(:thumb)
        self.preview_alt = first_photo.comment
      end
    end
  end

  def self.floor_and_flor_cnt_text(adv)
    floor_from = adv.floor_from
    floor_cnt_from = adv.floor_cnt_from

    floor_to = adv.floor_to
    floor_cnt_to = adv.floor_cnt_to

    if floor_from.present? && floor_cnt_from.present? && floor_to.blank? && floor_cnt_to.blank?
      "этаж #{floor_from}/#{floor_cnt_from}"
    else
      [
          AdvGenerator.enum_text(adv, :floor, '', 'этаж '),
          AdvGenerator.enum_text(adv, :floor_cnt, '', 'этажей ')
      ].delete_if{|e| e.to_s.strip == ''}.join(' ')
    end
  end

  def self.enum_text(adv, attr, units, prefix = nil, short = false)
    value_from = adv.send("#{attr}_from".to_sym)
    value_to = adv.send("#{attr}_to".to_sym)
    if value_from.present? && value_to.present? && value_from != value_to
      if short
        "#{prefix}от #{value_from}#{units}"
      else
        "#{prefix}от #{value_from} до #{value_to}#{units}"
      end
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
