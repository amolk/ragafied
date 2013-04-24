class AddMediaToLesson < ActiveRecord::Migration
  def self.up
    add_attachment :lessons, :main_audio
    add_attachment :lessons, :tanpura_audio
    add_attachment :lessons, :annotation_audio
  end

  def self.down
    remove_attachment :lessons, :main_audio
    remove_attachment :lessons, :tanpura_audio
    remove_attachment :lessons, :annotation_audio
  end
end
