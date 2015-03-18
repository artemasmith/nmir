# == Schema Information
#
# Table name: abuses
#
#  id                :integer          not null, primary key
#  advertisement_id  :integer
#  comment           :string(255)
#  user_id           :integer
#  abuse_type        :integer
#  status            :integer
#  moderator_comment :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class Abuse < ActiveRecord::Base
  belongs_to :advertisement
  belongs_to :user
  ABUSE_TYPES = [:agent, :expired, :deception, :engaged]
  STATUSES = [:wait, :accepted, :not_accepted]
  enum abuse_type: ABUSE_TYPES
  enum status: STATUSES

  rails_admin do
    field :status, :enum do
      enum do
        STATUSES
      end
    end
    field :abuse_type, :enum do
      enum do
        ABUSE_TYPES
      end
    end
    field :moderator_comment, :string
    field :comment, :string
    field :user do

    end
    #field :advertisement
    include_all_fields
  end
end
