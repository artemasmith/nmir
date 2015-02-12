class ImporterWorker
  include Sidekiq::Worker

  def perform file_path
    #do import here
    require 'rake'
    require 'pp'

    rake = Rake::Application.new
    Rake.application = rake
    rake.init
    rake.load_rakefile
    rake['import:donrio'].invoke(file_path)
  end
end