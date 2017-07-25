module GlitchWorks
  module Base

    def initialize (tag_name, params_string, tokens)
      super
      bind_params(eval("{#{params_string}}"))
    end

    def markdown_converter
      @context.registers[:site].find_converter_instance(::Jekyll::Converters::Markdown)
    end

    def id
      @context.registers[:page].id.split('/').last.gsub('-', '_').downcase
    end

    def category
      @context.registers[:page]['category']
    end
  end
end