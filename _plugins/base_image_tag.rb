require_relative 'glitchworks_tag'

class GlitchWorks::BaseImageTag < GlitchWorks::Tag
  
  def bind_params (params)
    @alt_texts = params[:alt_texts] || [params[:alt_text]]
    @files = params[:files] || [params[:file]]
  end

  def internal_render
    return_string = ['<div class="center">']

    @files.each_with_index { |file, idx| return_string << image_string(file, @alt_texts[idx]) }

    return_string << '</div>'
    return_string.join("\n")
  end
end
