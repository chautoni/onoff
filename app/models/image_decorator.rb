Spree::Image.class_eval do
  attr_accessible :color

  class Uploader < CarrierWave::Uploader::Base
    include CarrierWave::Compatibility::Paperclip
    include Cloudinary::CarrierWave

    process :convert => 'png'
    # Spree looks in attachment#errors, so just delegate to model#errors
    delegate :errors, :to => :model

    # Match the path defined in Spree::Image
    def paperclip_path
      "assets/products/:id/:style/:basename.:extension"
    end

    # These are the versions defined in Spree::Image
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

  mount_uploader :attachment, Uploader, :mount_on => :attachment_file_name

  # Get rid of the paperclip callbacks

  def save_attached_files; end
  def prepare_for_destroy; end
  def destroy_attached_files; end
end
