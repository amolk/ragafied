class Audio < ActiveRecord::Base
  attr_accessible :title, :file

  has_attached_file :file
end
