Spree::Admin::UsersController.class_eval do
  before_filter :authorize_super_admin
  
  private
  def authorize_super_admin
    unless current_user.super_admin?
      redirect_to admin_path
      flash[:error] = t(:authorization_failure)
    end
  end
end
