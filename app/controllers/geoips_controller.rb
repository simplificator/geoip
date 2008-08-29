class GeoipsController < ApplicationController
  def show()
    respond_to do |format|
      begin
        @ip = params[:ip]
        @range = IpRange.lookup(@ip)
        if @range # found a entry
          format.xml {render(:xml => @range.to_xml(:only => [:country, :country_code_2, :registry, :country_code_3, :assigned_at]))}
          format.csv {render(:text => @range.to_csv, :disposition => 'inline')}
        else # nothing found
          format.xml {render(:status => :not_found, :xml => '<not-found/>')}
          format.csv {render(:status => :not_found, :text => 'NOTFOUND')}
        end
      rescue RuntimeError => e # most likely troubles when converting IP
        format.xml {render(:status => 500, :xml => '<error/>')}
        format.csv {render(:status => 500, :text => 'errpr')}
      end
    end
  end
  
  
  def whatsmyip
    @ip = request.remote_ip
    @range = IpRange.lookup(@ip)
  end
end
