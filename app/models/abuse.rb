class Abuse < ActiveRecord::Base
  belongs_to :advertisement
  ABUSE_TYPES = [:agent, :expired, :deception, :engaged]
  STATUSES = [:wait, :accepted, :not_accepted]
  enum abuse_type: ABUSE_TYPES
  enum status: STATUSES
end
