class LocationsController < ApplicationController
  def index
    children = {}
    if params[:parents]
      parents = params[:parents].split
      parents.each do |p|
        pname = Location.find_by_id(p.to_i).title
        children[pname] = Location.get_children(p).map{ |l| [l.title, l.id] }
      end
    else
      children = "We got no parents params"
    end
    log = Logger.new(STDOUT)
    log.fatal(children)
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
