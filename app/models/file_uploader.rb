class FileUploader
  def save(file)
    name =  upload['datafile'].original_filename
    directory = "public/data"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end

  def cleanup
    File.delete("#{RAILS_ROOT}/public/import/#{@filename}") if File.exist?("#{RAILS_ROOT}/dirname/#{@filename}")
  end

end