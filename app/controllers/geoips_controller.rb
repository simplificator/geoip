class GeoipsController < ApplicationController  
  def whatsmyip
    @ip = request.remote_ip
    @range = IpRange.lookup(@ip)
  end
end
