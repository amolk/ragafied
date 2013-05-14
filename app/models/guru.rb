class Guru < ActiveRecord::Base
  attr_accessible :name, :image
  has_many :lessons
  has_attached_file :image,
    :styles => {
      :gallery => "350x600>"}
end
