module AssociationPagination
  # overwrite this in your association
  def page_order
      'id DESC'
  end

  def page(page)
    paginate :page => (page || 1), :order => page_order, :per_page => 10
  end
end
