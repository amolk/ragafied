class Lesson < ActiveRecord::Base
  attr_accessible :composition, :raga_id, :guru_id, :audios, :audios_attributes

  belongs_to :raga
  belongs_to :guru
  has_many :audios
  accepts_nested_attributes_for :audios

  def lesson_composition
    JSON.parse(read_attribute(:composition))
  end

  def raga_name
    raga.name
  end

  def guru_name
    guru.name
  end

  def audio_files
    info = {}
    audios.each {|audio| info[audio.title] = {url: audio.file.url}}
    info
  end
end
