Spree::Admin::NavigationHelper.class_eval do
	def configurations_sidebar_menu_item(link_text, url, options = {})

    is_active = url.ends_with?(controller.controller_name) || (url.ends_with?( "#{controller.controller_name}/edit") && controller.action_name == 'edit') || (url.ends_with?( "#{controller.controller_name}/homepage") && (['homepage_slideshow', 'edit_homepage_slideshow'].include?(controller.action_name)))
    options.merge!(:class => is_active ? 'active' : nil)
    content_tag(:li, options) do
      link_to(link_text, url)
    end
  end
end
