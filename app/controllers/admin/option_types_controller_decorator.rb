Spree::Admin::OptionTypesController.class_eval do

  def update
    option_type = Spree::OptionType.find(params[:id])
    if option_type
      params[:option_type][:option_values_attributes].each { |k,v| v[:presentation] = v[:name] if v[:presentation].blank? }
      if option_type.update_attributes(params[:option_type])
        flash[:success] = flash_message_for(option_type, :successfully_updated)
      else
        flash[:error] = "Update unsuccessfully"
      end
    else
      flash[:error] = flash_message_for(Spree::OptionType.new, :not_found)
    end
    redirect_to edit_admin_option_type_path(option_type)
  end
end
