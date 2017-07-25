require_relative 'glitchworks_base'

module GlitchWorks
  class Block < Liquid::Block
    include GlitchWorks::Base

    def render (context)
      @context = context
      @text = super
      internal_render
    end
  end
end