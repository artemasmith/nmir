class Api::ValidationController < ApplicationController
  def create

    if params[:user].try(:[], :email).present?
      return render js: { valid: User.find_by_email(params[:user].try(:[], :email)).blank? }.to_json
    end

    if params[:advertisement].try(:[], :user_attributes).try(:[], :email).present?
      return render js: { valid: User.find_by_email(params[:advertisement].try(:[], :user_attributes).try(:[], :email)).blank? }.to_json
    end

    if params[:advertisement].try(:[], :user_attributes).try(:[], :phones_attributes).try(:first).try(:last).try(:[], :original).present?
      return render js: {
          valid: Advertisement
          .joins('INNER JOIN "phones" ON "advertisements"."user_id" = "phones"."user_id"')
          .where('phones.number' => Phone.normalize(params[:advertisement].try(:[], :user_attributes).try(:[], :phones_attributes).try(:first).try(:last).try(:[], :original)))
          .first.blank?
      }.to_json
    end

    if params[:user].try(:[], :phones_attributes).try(:first).try(:last).try(:[], :original).present?
      return render js: {
                        valid: Advertisement
                                   .joins('INNER JOIN "phones" ON "advertisements"."user_id" = "phones"."user_id"')
                                   .where('phones.number' => Phone.normalize(params[:user].try(:[], :phones_attributes).try(:first).try(:last).try(:[], :original)))
                                   .first.blank?
                    }.to_json
    end
  end

  def check_if_specific
    if params[:ids].present?
      params[:ids].split(',').each do |loc_id|
        is_not_region = Location.location_types[Location.find(loc_id.to_i).location_type] > 0
        return render js: { valid: true }.to_json if is_not_region
      end
    end
    return render js: { valid: false }.to_json
  end
end
