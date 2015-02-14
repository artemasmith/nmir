class FileUploader
  def self.save(upload)
    name =  upload.original_filename
    name = name.sub(/[^\w\.\-]/,'_')
    if Rails.env.production?
      directory = Rails.root.join('..', 'shared', 'public', 'import')
    else
      directory = Rails.root.join('public', 'import')
    end
    FileUtils.mkdir_p(directory) unless File.exists?(directory)
    # create the file path
    path = File.join(directory, name)

    File.delete(path) if File.exist?(path)
    # write the file
    File.open(path, "wb") { |f| f.write(upload.tempfile.read) }
    result = { file_path: path }
    result[:error] = 'Could not create file' if File.size(path) != upload.tempfile.size
    return result
  end

end