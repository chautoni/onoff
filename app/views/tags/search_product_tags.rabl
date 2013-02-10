object false
child(@tags => :tags) do
  attributes :name
  node(:id) { |tag| tag.name  }
end

