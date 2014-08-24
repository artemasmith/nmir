class LocationsController < ApplicationController
  def index
    @locations = Location.all.map { |l| [l.title, l.id] }
    children = {}
    if params[:parents]
      parents = params[:parents].split
      parents.each do |p|
        pname = Location.search(p).first.title
        children[pname] = Location.get_children(p).map{ |l| [l.title, l.id] }
      end
    else
      children = "We got no parents params"
    end
    respond_to do |format|
      format.js
      format.json { render json: children }
    end
  end

  def show
    respond_to do |format|
      format.js
    end
  end
end
