class ImporterWorker
  include Sidekiq::Worker

  def import_donrio file_path
    #do import here
  end
end