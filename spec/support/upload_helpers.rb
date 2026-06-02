module UploadHelpers
  def invalid_type_upload
    file = Tempfile.new(['test', '.txt'])
    file.write('not an image')
    file.rewind
    Rack::Test::UploadedFile.new(file.path, 'text/plain')
  end

  def gif_upload
    file = Tempfile.new(['test', '.gif'])
    file.write('GIF89a fake gif')
    file.rewind
    Rack::Test::UploadedFile.new(file.path, 'image/gif')
  end

  def oversized_upload(content_type: 'image/jpeg')
    file = Tempfile.new(['oversized', '.jpg'])
    file.write('a' * (ImageAttachable::MAX_FILE_SIZE + 1).to_i)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end

  def valid_image_upload(content_type: 'image/jpeg')
    file = Tempfile.new(['valid', '.jpg'])
    file.write('fake image bytes')
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end
end

RSpec.configure do |config|
  config.include UploadHelpers, type: :request
end
