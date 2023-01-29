require_relative 'base_image_tag'

class GlitchWorks::ImageTag < GlitchWorks::BaseImageTag

  private

  def image_string (file, alt_text)
    "  <img src='/~glitch/images/#{category}/#{id}/#{file}' alt='#{alt_text}'>"
  end
end

Liquid::Template.register_tag('image', GlitchWorks::ImageTag)
