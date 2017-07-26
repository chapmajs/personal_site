require_relative 'glitchworks_tag'

class GlitchWorks::LinkedImageTag < GlitchWorks::Tag
  
  def bind_params (params)
    @alt_texts = params[:alt_texts] || [params[:alt_text]]
    @files = params[:files] || [params[:file]]
  end

  def internal_render
    return_string = ['<div class="center">']

    @files.each_with_index { |file, idx| return_string << linked_image_string(file, @alt_texts[idx]) }

    return_string << '</div>'
    return_string.join("\n")
  end

  private

  def linked_image_string (file, alt_text)
    "  <a href='/images/#{category}/#{id}/#{file}'><img src='/images/#{category}/#{id}/scaled/#{file}' alt='#{alt_text}'></a>"
  end
end

Liquid::Template.register_tag('linked_image', GlitchWorks::LinkedImageTag)