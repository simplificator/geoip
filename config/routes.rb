ActionController::Routing::Routes.draw do |map|
  map.connect('ip_ranges/:id.:format', :controller => 'ip_ranges', :action => 'show', :conditions => {:method => :get})
  map.connect('geoips/whatsmyip', :controller => 'geoips', :action => 'whatsmyip', :condtions => {:method => :get})
end
