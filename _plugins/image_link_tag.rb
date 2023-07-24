require_relative 'glitchworks_tag'

class GlitchWorks::ImageLinkTag < GlitchWorks::Tag
  
  def bind_params (params)
    @alt_text = params[:alt_text]
    @file = params[:file]
    @link = params[:link]
  end

  def internal_render
    return_string = ['<div class="center">']
	return_string << image_string(@file, @alt_text, @link)
    return_string << '</div>'
    return_string.join("\n")
  end

  private

  def image_string (file, alt_text, link)
    "  <a href='#{link}'><img src='/~glitch/images/#{category}/#{id}/#{file}' alt='#{alt_text}'></a>"
  end
end

Liquid::Template.register_tag('image_link', GlitchWorks::ImageLinkTag)
