# == Schema Information
#
# Table name: notepads
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  advertisement_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Notepad < ActiveRecord::Base
end
