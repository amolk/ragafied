class Lesson < ActiveRecord::Base
  attr_accessible :phrases, :raga_id, :guru_id
  belongs_to :raga
  belongs_to :guru
end
