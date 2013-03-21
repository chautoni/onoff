# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



# Spree::Core::Engine.load_seed if defined?(Spree::Core)
# Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

# Loads seed data out of default dir
default_path = File.join(File.dirname(__FILE__), 'default')

Rake::Task['db:load_dir'].reenable
Rake::Task['db:load_dir'].invoke(default_path)

Spree::OptionType.create(:name => 'color', :presentation => 'Màu') unless Spree::OptionType.exists?(name: 'color')
Spree::OptionType.create(:name => 'size', :presentation => 'Size') unless Spree::OptionType.exists?(name: 'size')

Spree::Property.create(:name => 'unit', :presentation => 'Đơn Vị Tính') unless Spree::Property.find_by_name('unit')

asia_zone = Spree::Zone.find_or_create_by_name('Asia')
asia_zone.zone_members.create(:zoneable_id => 219, :zoneable_type => 'Spree::Country') if asia_zone.zone_members.empty?

Spree::Role.find_or_create_by_name('super_admin')

collection = Spree::Taxonomy.find_or_create_by_name('collections')
collection.taxons.find_or_create_by_name('Thể thao')
collection.taxons.find_or_create_by_name('Năng động')
collection.taxons.find_or_create_by_name('Công sở')
collection.taxons.find_or_create_by_name('Golf')

branches = Spree::Taxonomy.find_or_create_by_name('branches')
branches.taxons.find_or_create_by_name('Vớ')
branches.taxons.find_or_create_by_name('Quần lót')
branches.taxons.find_or_create_by_name('Áo lót')
