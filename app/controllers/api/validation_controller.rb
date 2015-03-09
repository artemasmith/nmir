class Api::ValidationController < ApplicationController
  def create
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
end
