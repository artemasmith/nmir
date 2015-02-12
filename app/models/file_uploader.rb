class FileUploader
  def self.save(upload)
    name =  upload.original_filename
    name = name.sub(/[^\w\.\-]/,'_')
    directory = "public/import"
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