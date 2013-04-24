class Lesson < ActiveRecord::Base
  attr_accessible :phrases, :raga_id, :guru_id, :main_audio, :tanpura_audio, :annotation_audio

  belongs_to :raga
  belongs_to :guru

  has_attached_file :main_audio
  has_attached_file :tanpura_audio
  has_attached_file :annotation_audio

  def raga_name
    raga.name
  end

  def guru_name
    guru.name
  end

  def main_audio_url
    main_audio.url
  end

  def tanpura_audio_url
    tanpura_audio.url
  end

  def annotation_audio_url
    annotation_audio.url
  end
end
