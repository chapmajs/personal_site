class GlitchWorks::TextBlock < GlitchWorks::Block

  def bind_params (params)
    @title = params[:title]
  end

  def internal_render
    <<~TEXTBLOCK
    <div class="pageview">
      <div class="pageview-header codeblock-header">.:[#{@title}]:.</div>
        <pre>#{@text}</pre>
    </div>
    TEXTBLOCK
  end
end

Liquid::Template.register_tag('textblock', GlitchWorks::TextBlock)