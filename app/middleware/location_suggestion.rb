class LocationSuggestion
  def initialize(app)
    @app = app
  end
  def call(env)
    if env["PATH_INFO"] == "/street_houses"
      request = Rack::Request.new(env)
      terms = Location.suggest_location(request.params["parent_id"],request.params["term"])
      [200, {"Content-Type" => "appication/json"}, [terms.to_json]]
    else
      @app.call(env)
    end
  end
end