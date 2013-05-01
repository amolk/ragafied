class CreateAudios < ActiveRecord::Migration
  def change
    create_table :audios do |t|
      t.string :title
      t.integer :lesson_id

      t.timestamps
    end
    add_attachment :audios, :file
  end
end
