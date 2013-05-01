class RenameLessonPhrasesToComposition < ActiveRecord::Migration
  def up
    rename_column :lessons, :phrases, :composition
  end

  def down
    rename_column :lessons, :composition, :phrases
  end
end
