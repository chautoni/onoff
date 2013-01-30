module ApplicationHelper
	def link_to_remove(name, f)
    link_to_function(name, "remove_fields(this)", :class => 'remove-image-link')
  end
end
