class TagsController < Spree::Admin::BaseController
  respond_to :json
  def search_product_tags
    if params[:ids]
      @tags = ActsAsTaggableOn::Tag.where(id: params[:ids].split(','))
    else
      @tags = ActsAsTaggableOn::Tag
      .limit(20).joins("left join taggings on taggings.id = tags.id and taggings.taggable_type = 'Spree::Product'")
      .search(:name_cont => params[:q]).result
    end
  end
end

