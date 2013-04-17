class CreateRagas < ActiveRecord::Migration
  def change
    create_table :ragas do |t|
      t.string :name

      t.timestamps
    end
  end
end
