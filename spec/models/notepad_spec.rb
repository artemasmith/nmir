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

require 'rails_helper'

RSpec.describe Notepad, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
