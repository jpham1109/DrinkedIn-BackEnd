require 'rails_helper'

RSpec.describe ProcessImageVariantJob, type: :job do
  # A real (if tiny) 1x1 PNG — vips needs decodable image bytes to process a
  # variant, unlike the upload-validation specs which only check
  # content-type/size and can use fake bytes.
  let(:valid_png_bytes) do
    Base64.decode64(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACXBIWXMAAAPoAAAD6AG1e1JrAAAACklEQVQImWNgAAAAAgAB9HFkpgAAAABJRU5ErkJggg=='
    )
  end

  def attach_real_image(record)
    file = Tempfile.new(['test', '.png'], binmode: true)
    file.write(valid_png_bytes)
    file.rewind
    record.image.attach(io: file, filename: 'test.png', content_type: 'image/png')
  end

  describe '#perform' do
    it 'processes the standard variant for an attached image without raising' do
      cocktail = create(:cocktail)
      attach_real_image(cocktail)

      expect { described_class.perform_now(cocktail) }.not_to raise_error
    end

    it 'is a no-op when the record has no image attached' do
      cocktail = create(:cocktail)

      expect(cocktail.image).not_to be_attached
      expect { described_class.perform_now(cocktail) }.not_to raise_error
    end

    it 'works the same for a User avatar' do
      user = create(:user)
      attach_real_image(user)

      expect { described_class.perform_now(user) }.not_to raise_error
    end
  end

  describe 'retry policy' do
    it 'retries on StandardError' do
      handler_classes = described_class.rescue_handlers.map(&:first)
      expect(handler_classes).to include('StandardError')
    end
  end
end
