module Aliexpress

  class ValidRefreshTokenException < RuntimeError; end

  class ValidAccessTokenException < RuntimeError; end

  class MediaTypeException < RuntimeError; end

  class ImageTypeException < RuntimeError; end
end