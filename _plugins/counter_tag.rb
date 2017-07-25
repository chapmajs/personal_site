require_relative 'glitchworks_tag'

module GlitchWorks
  class CounterTag < GlitchWorks::Tag
    
    def bind_params (params)
      @text = params[:text]
    end

    def internal_render
      <<~COUNTER
      <p class="center">
          <script language="javascript" src="https://services.theglitchworks.net/counters/#{id}"></script> #{@text}
      </p>
      COUNTER
    end
  
  end
end

Liquid::Template.register_tag('counter', GlitchWorks::CounterTag)