require 'cancan'

Spree::Ability.class_eval do
  include CanCan::Ability
  def initialize(user)
    self.clear_aliased_actions

    # override cancan default aliasing (we don't want to differentiate between read and index)
    alias_action :edit, :to => :update
    alias_action :new, :to => :create
    alias_action :new_action, :to => :create
    alias_action :show, :to => :read
    alias_action :delete, :to => :destroy

    user ||= Spree.user_class.new
    if user.respond_to?(:has_spree_role?) && (user.has_spree_role?('admin') || user.has_spree_role?('super_admin'))
      can :manage, :all
    else
      #############################
      can [:read,:update,:destroy], Spree.user_class, :id => user.id
      can :create, Spree.user_class
      #############################
      can :read, Order do |order, token|
        order.user == user || order.token && token == order.token
      end
      can :update, Order do |order, token|
        order.user == user || order.token && token == order.token
      end
      can :create, Order

      can :read, Address do |address|
        address.user == user
      end

      #############################
      can :read, Product
      can :index, Product
      #############################
      can :read, Taxon
      can :index, Taxon
      #############################
    end

    #include any abilities registered by extensions, etc.
    Spree::Ability.abilities.each do |clazz|
      ability = clazz.send(:new, user)
      @rules = rules + ability.send(:rules)
    end
  end
end
