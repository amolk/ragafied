ActiveAdmin.register Lesson do
  form html: { multipart: true }  do |f|
    f.inputs  do
      f.input :raga
      f.input :guru
      f.input :phrases
      f.input :main_audio, :as => :file
      f.input :tanpura_audio, :as => :file
      f.input :annotation_audio, :as => :file
    end            
    f.buttons
  end  
end