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
    field :created_at
    field :status, :enum do
      enum do
        STATUSES.each_with_index.map { |i,j| [i,j]}
      end
    end
    field :abuse_type, :enum do
      enum do
        ABUSE_TYPES.each_with_index.map { |i,j| [i,j]}
      end
    end
    field :moderator_comment, :string
    field :comment, :string
    field :user do
    end
    field :advertisement do
    end
    #include_all_fields
  end

  protected

  def inform_users
    #update other abuses on this advertisement
    puts "SELF STATUS = #{self.status} STATUS = #{status}\n\n"
    Abuse.where(advertisement_id: self.advertisement_id).update_all(status: STATUSES.index(self.status.to_sym))


    #inform users
    users = Abuse.where(advertisement_id: self.advertisement_id).map(&:user_id).uniq.delete_if { |id| id.blank? }
    users << self.advertisement.user_id
    puts "users = #{users}\n"
    emails = users.map { |u| User.find(u).email }
    AbuseMailer.inform(emails, self).deliver

    #update user role
    if self.status == 'accepted' && self.abuse_type == 'agent'
      self.advertisement.user.update(role: :agent)
    end

    #update advertisement status_type
    if self.status == 'accepted'
      self.advertisement.update(status_type: 2)
    end
  end

end
