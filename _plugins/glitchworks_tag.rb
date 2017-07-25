module GlitchWorks
  class Tag < Liquid::Tag

    include GlitchWorks::Base

    def render (context)
      @context = context
      internal_render
    end
  end
end