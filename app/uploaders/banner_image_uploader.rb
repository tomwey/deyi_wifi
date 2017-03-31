# encoding: utf-8

class BannerImageUploader < BaseUploader

  storage :qiniu
  # storage :file

  version :large do
    process resize_to_fill: [1080, 580]
  end
  
  version :thumb do
    process resize_to_fill: [540, 290]
  end
  
  version :small do
    process resize_to_fill: [138, 80]
  end

  def filename
    if super.present?
      "#{secure_token}.#{file.extension}"
    end
  end
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  def extension_white_list
    %w(jpg jpeg png gif)
  end
  
  protected
    def secure_token
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
    end

end
