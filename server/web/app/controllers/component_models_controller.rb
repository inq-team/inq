class ComponentModelsController < ApplicationController

  def short_name
        @model = ComponentModel.find(params[:id])
        @short_name = @model.short_name || ''

        render :layout => 'popup'
  end

  def set_short_name
        @model = ComponentModel.find(params[:id])
        @short_name = params[:short_name]
        @model.short_name = @short_name
        unless @model.save
                flash[:error] = @model.errors
                render :action => 'short_name', :layout => 'popup'
	else
	        render :layout => 'popup'
        end
  end

end

