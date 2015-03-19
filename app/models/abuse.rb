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

  validates :abuse_type, presence: true
  validates :advertisement_id, presence: true

  after_update :inform_users, if: Proc.new { |abuse| abuse.status == 'accepted' || abuse.status == 'not_accepted' }

  rails_admin do
    firld :created_at
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

  protected

  def inform_users
    Abuse.where(advertisement_id: self.advertisement_id).update_all(status: self.status)
    users = Abuse.where(advertisement_id: self.advertisement_id).map(&:user_id).delete_if { |id| id.blank? }
    users << self.advertisement.user_id
    puts "users = #{users}\n"
    emails = users.map { |u| User.find(u).email }
    body = ""
    AbuseMailer.inform(emails, self).deliver
  end
end
