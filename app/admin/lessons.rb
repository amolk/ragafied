ActiveAdmin.register Lesson do
  form html: { multipart: true }  do |f|
    f.inputs  do
      f.input :raga
      f.input :guru
      f.input :composition
      f.has_many :audios do |ff|
        ff.input :title
        ff.input :file, as: :file
        ff.input :_destroy, as: :boolean
      end 
    end            
    f.buttons
  end  
end