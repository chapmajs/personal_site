module GlitchWorks
  class CodeBlock < Jekyll::Tags::HighlightBlock

    def initialize (tag_name, params_string, tokens)
      bind_params(eval("{#{params_string}}"))
      super(tag_name, @language, tokens)
    end

    def bind_params (params)
      @title = params[:title]
      @language = params[:language] or raise SyntaxError, "Error in tag 'codeblock', :language parameter is required"
    end

    def render (context)
      @context = context
      @text = super
      internal_render
    end

    def internal_render
      <<~CODEBLOCK
      <div class="pageview">
        <div class="pageview-header codeblock-header">.:[#{@title}]:.</div>
          #{@text}
      </div>
      CODEBLOCK
    end
  end
end

Liquid::Template.register_tag('codeblock', GlitchWorks::CodeBlock)