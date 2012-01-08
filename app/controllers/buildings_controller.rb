class BuildingsController < ApplicationController
  def index
    authorize! :edit_buildings, :all
    @buildings = Building.all.sort { |a, b| a.abbrv <=> b.abbrv }
  end

  def update
    authorize! :edit_buildings, :all
    msg = ""
    if (params[:building_abbrv_new] != "") || (params[:building_name_new] != "") || (params[:building_url_new] != nil)
      logger.info ">> #{params[:building_abbrv_new].inspect}, #{params[:building_name_new].inspect}, #{params[:building_url_new].inspect}"
      b = Building.new(:abbrv => params[:building_abbrv_new],
                          :name => params[:building_name_new],
                          :url => params[:building_url_new])
      b.save
      msg << "New building: " << b.errors.full_messages.join(" ") << "<br/>" if not (b.errors.empty?)
    end
    params.each_pair do |k,v|
      next unless k =~ /^building_(.*)_(\d+)/
      b = Building.find($2)
      case $1
      when "abbrv", "name", "url" # only valid attrs
        next if b.send($1) == v   # unchanged
        old_abbrv = b.abbrv
        b.send("#{$1}=", v)       # set value
        b.save
        msg << "#{old_abbrv}: " + b.errors.full_messages.join(" ") << "<br/>" if not (b.errors.empty?)
      else
        next
      end
    end
    redirect_to buildings_index_path, :alert => msg.html_safe
  end

  def destroy
    authorize! :edit_buildings, :all
    b = Building.find(params[:id])
    abbrv = b.abbrv
    b.destroy
    redirect_to buildings_index_path, :alert => "Building #{abbrv} deleted"
  end
end
