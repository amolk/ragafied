class AddImageToGuru < ActiveRecord::Migration
  def change
    add_attachment :gurus, :image
  end
end
