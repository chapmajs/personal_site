module GlitchWorks
  class Tag < Liquid::Tag

    def initialize (tag_name, params_string, tokens)
      super
      bind_params(eval("{#{params_string}}"))
    end

    def render (context)
      @context = context
      internal_render
    end

    def id
      @context.registers[:page].id.split('/').last.sub('-', '_').downcase
    end

    def category
      @context.registers[:page]['category']
    end
  end
end