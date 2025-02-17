require_relative 'glitchworks_tag'

class GlitchWorks::ContactTag < GlitchWorks::Tag
  
  def bind_params (params)
    @text = params[:text] || 'contact us'
  end

  def internal_render
    "<a href='https://rails-services.glitchworks.net/messages/new'>#{@text}</a>"
  end
end

Liquid::Template.register_tag('contact', GlitchWorks::ContactTag)
