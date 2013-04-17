class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.integer :raga_id
      t.integer :guru_id
      t.text :phrases

      t.timestamps
    end
  end
end
