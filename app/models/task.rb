class Task < ActiveRecord::Base
  belongs_to :user
  simply_versioned 

  def version
    versions.current.number
  end

  def add_view
    increment! :views
  end

  def approve
    update_attributes(:approved => true)
  end

  def self.recent(options = {})
    find_options = { :order => 'id DESC', :limit => 5 }
    find(:all, find_options.merge(options))
  end
end
