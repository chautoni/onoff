Spree::User.class_eval do
  users_table_name = Spree::User.table_name
  roles_table_name = Spree::Role.table_name

  scope :super_admin, lambda { includes(:spree_roles).where("#{roles_table_name}.name" => "super_admin") }

  def super_admin?
    Spree::User.super_admin.include? self
  end

  def self.admin_created?
    Spree::User.admin.count + Spree::User.super_admin.count > 0
  end
end
