class ImporterWorker
  include Sidekiq::Worker

  def perform file_path, email

    _, stdout, stderr = Open3.popen3("RAILS_ENV=\"production\" bundle exec rake import:donrio[\"#{file_path}\"]")
    body = stdout.read + stderr.read

    File.delete(file_path)
    ImporterMailer.finish(email, body).deliver
  end
end