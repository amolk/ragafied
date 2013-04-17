class CreateGurus < ActiveRecord::Migration
  def change
    create_table :gurus do |t|
      t.string :name

      t.timestamps
    end
  end
end
