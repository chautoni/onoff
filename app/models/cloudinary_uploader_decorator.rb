CloudinaryUploader.class_eval do
  version :mini do
    process :resize_to_fit => [125, 125]
  end

  version :small do
    process :resize_to_fit => [300, 300]
  end

  version :product do
    process :resize_to_fit => [510, 510]
  end

  version :large do
    process :resize_to_fit => [1000, 1000]
  end

  version :feature do
    process :resize_to_fit => [460, 460]
  end
end
