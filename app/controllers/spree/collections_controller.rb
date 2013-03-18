# encoding: utf-8

module Spree
  class CollectionsController < Spree::StoreController
  	helper 'spree/products'

    def index
    	params[:collection_name] = params[:collection_name].try(:gsub, *['-', ' '])
      @collection_name = params[:collection_name] || Spree::Taxonomy.find_by_name('Bộ sưu tập').taxons.first.name
      @header_color = 'white'
    end
  end
end
