class RemoveAdvertisementsPrivateComment < ActiveRecord::Migration
  def change
    remove_column :advertisements, :private_comment
  end
end
