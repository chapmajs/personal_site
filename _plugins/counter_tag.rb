require_relative 'glitchworks_tag'

class GlitchWorks::CounterTag < GlitchWorks::Tag
  
  def bind_params (params)
    @text = params[:text]
    @id = params[:id]
  end

  def id
    @id || super
  end

  def internal_render
    <<~COUNTER
    <p class="center">
        <script language="javascript" src="https://counters.glitchworks.net/#{id}"></script> #{@text}
    </p>
    COUNTER
  end
end

Liquid::Template.register_tag('counter', GlitchWorks::CounterTag)