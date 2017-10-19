require_relative 'base_image_tag'

class GlitchWorks::LinkedImageTag < GlitchWorks::BaseImageTag
  
  private

  def image_string (file, alt_text)
    "  <a href='/images/#{category}/#{id}/#{file}'><img src='/images/#{category}/#{id}/scaled/#{file}' alt='#{alt_text}'></a>"
  end
end

Liquid::Template.register_tag('linked_image', GlitchWorks::LinkedImageTag)
