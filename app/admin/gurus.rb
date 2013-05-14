ActiveAdmin.register Guru do
  form do |f|
    f.inputs do
      f.input :name
      f.input :image, as: :file
      f.buttons
    end
  end
end
