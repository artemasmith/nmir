class ImporterWorker
  include Sidekiq::Worker

  def perform file_path, email
    #do import here
    require 'rake'
    require 'pp'

    rake = Rake::Application.new
    Rake.application = rake
    rake.init
    rake.load_rakefile
    rake['import:donrio'].invoke(file_path)
    ImporterMailer.finish(email)
  end
end