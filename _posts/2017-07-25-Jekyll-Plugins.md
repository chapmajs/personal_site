---
layout: post
title: Jekyll Plugins, Custom Liquid Tags and Blocks
topic: Custom Liquid tags and blocks via Jekyll plugins
category: coding
description: During a recent bit of site maintenance, I DRYed up the Jekyll project for glitchwrks.com by creating custom Liquid tags and blocks for the site. These reduce code duplication, simplify and centralize configuration, and make the Markdown for writeups nicer.
image: ruby.png
---

This site is largely a static site, built with the help of [Jekyll](https://jekyllrb.com/). Jekyll essentially takes some templates, a bunch of Markdown (or your choice of markup language), and turns out HTML suitable for direct deployment to a HTTP server. Jekyll replaced a bunch of static HTML and maintenance scripts [in April 2012](http://www.glitchwrks.com/2012/04/20/jekyll-upgrade). It's a nice, "blog aware" solution that doesn't involve running anything server-side. It's also written in Ruby, which is one of my preferred languages. Being open source means it's easy to hack on, and recent site maintenance brought a few points to mind that got me to actually write some plugins for Jekyll.

There were a few consistent pain points across the Markdown source for the site, as follows:

* Linked thumbnail images required a lot of boilerplate and manual editing
* Contact form links were scattered everywhere and required a lot of updating if URLs changed (they have three times, as of writing)
* Counter includes were not great, and resulted in an extra paragraph element
* "Danger" warnings at the top of articles required a block of HTML
* Plaintext and highlighted code blocks needed more graphical separation from writeup text

Fortunately, plugin support is included in Jekyll. I started with [the official documentation](http://jekyllrb.com/docs/plugins/), finding that Liquid tags would probably solve most of my problems. Starting with a custom counter tag seemed like an easy, straightforward start. By the time I was ready to start on the linked image tag, I'd already found a pattern for custom tags that I liked. Rather than start at the earliest steps, we will begin with conventions I settled on for custom tags.

Plugin Structure, Basic Tag Setup
---------------------------------

In the simplest case, custom plugins are located under the `_plugins` directory in your Jekyll project. Seeing as how my plugins were to be tightly coupled to glitchwrks.com, I didn't see the benefit into breaking them out into separate gems. For now, they live under `_plugins`.

The offical documentation for writing custom tags starts off with extending `Liquid::Tag` in a class within the `Jekyll` module. The most basic Liquid tag simply extends `Liquid::Tag` and implements the `render` method, taking one parameter (the context) and returning a string containing the HTML to be rendered. Tags are set up with the `initialize` method which, if implemented, must take three arguments and call `super` at some point. Tags must be registered with the Liquid template engine to make them available in templates. The tags for this site largely inherit from a base class, `GlitchWorks::Tag`, which implemets this base functionality and a few other convenience methods. Let's take a look at it:

{% codeblock :language => 'ruby', :title => '_plugins/glitchworks_tag.rb' %}
require_relative 'glitchworks_base'

module GlitchWorks
  class Tag < Liquid::Tag
    include GlitchWorks::Base

    def render (context)
      @context = context
      internal_render
    end
  end
end
{% endcodeblock %}

This class depends on `GlitchWorks::Base`, which is a module that contains some methods common to both tags and blocks. It looks like this:

{% codeblock :language => 'ruby', :title => '_plugins/glitchworks_base.rb' %}
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
{% endcodeblock %}

Here we can see that the `initialize` method expects the third parameter to be a params string, which it evals and passes into `bind_params`, which is not implemented in either `GlitchWorks::Base` or `GlitchWorks::Tag`. Rather than doing work directly in the `render` method, the tag class assigns the context to an instance variable, and calls `internal_render` which is again implemented by subclasses only.

The helper (or [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter)) methods in `GlitchWorks::Base` include some useful tools that were not readily apparent from either the Jekyll or Liquid documentation. `markdown_converter` grabs an instance of the configured Markdown parser from the project configuration. `id` parses this site's concept of a writeup ID out of the information Jekyll makes available to us (`@context.registers[:page].id` returns the full permalink). `category` pulls the page's category.

Note that the `:page` element on the registers is a recentish addition to Jekyll, as discussed in [this StackOverflow post](https://stackoverflow.com/questions/7478731/how-do-i-detect-the-current-page-in-a-jekyll-tag-plugin?rq=1). Doing an `inspect` on `registers[:page]` results in an overwhelming heap of output. It returns an instance of `Jekyll::Drops::DocumentDrop`, which behaves somewhat like a hash.

The Counter Tag, a Simple Case
------------------------------

As mentioned, this rabbit hole was entered due to the want for a simpler way of including counters on pages. This site's counters are provided by [a small Sinatra app](https://github.com/chapmajs/site_services) and included as JavaScript that immediately does a `document.write()` with the hit count. Here's the code for the `counter` tag, which accomplishes this:

{% codeblock :language => 'ruby', :title => '_plugins/counter_tag.rb' %}
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
        <script language="javascript" src="https://services.theglitchworks.net/counters/#{id}"></script> #{@text}
    </p>
    COUNTER
  end
end

Liquid::Template.register_tag('counter', GlitchWorks::CounterTag)
{% endcodeblock %}

The counter tag inherits from `GlitchWorks::Tag` and implements the two methods referenced but not implemented in either the parent class or the base module: `bind_params` and `internal_render`. It also overrides the `id` method, allowing for an optional ID to be supplied when the tag is called. This feature was included since some of the early hit counters on this site are referenced by an ID that does not match what the `id` method returns.

The final line in the file registers `GlitchWorks::CounterTag` as the `counter` tag with the Liquid template engine, allowing it to be called as such:

`{% raw %}{% counter :id => 'foo', :text => 'bar baz' %}{% endraw %}`

and producing the output:

{% highlight html %}
{% counter :id => 'foo', :text => 'bar baz' %}
{% endhighlight %}

(fun fact: the above is generated directly with the tag plugin)

This tag essentially defined my tag and block calling convention: the first keyword is the name of the tag, and everything after it gets passed to the second argument in the `initialize` method of the tag class. As seen in `GlitchWorks::Base`, our `initialize` method evals the second argument and passes it off to `bind_params`. All of the plugins for this site treat the string as a string representation of a Ruby hash.

Linked Image Thumbnails
-----------------------

The second custom tag created helps with thumbnail images in writeups, which have alt text and are linked to a full resolution version. Every writeup follows the convention of storing images in `/images/category/id`. Thumbnails are stored in `/images/category/id/scaled` and always have the same filename as the full-size image. This pattern is great for organization, but was somewhat verbose when using standard Markdown linked image syntax. Here's the tag plugin that handles linked images:

{% codeblock :language => 'ruby', :title => '_plugins/linked_image_tag.rb' %}
require_relative 'glitchworks_tag'

class GlitchWorks::LinkedImageTag < GlitchWorks::Tag
  
  def bind_params (params)
    @alt_texts = params[:alt_texts] || [params[:alt_text]]
    @files = params[:files] || [params[:file]]
  end

  def internal_render
    return_string = ['<div class="center">']

    @files.each_with_index { |file, idx| return_string << linked_image_string(file, @alt_texts[idx]) }

    return_string << '</div>'
    return_string.join("\n")
  end

  private

  def linked_image_string (file, alt_text)
    "  <a href='/images/#{category}/#{id}/#{file}'><img src='/images/#{category}/#{id}/scaled/#{file}' alt='#{alt_text}'></a>"
  end
end

Liquid::Template.register_tag('linked_image', GlitchWorks::LinkedImageTag)
{% endcodeblock %}

This tag is meant to handle the case of a single linked image, as well as multiple linked images centered within the same `<div>` -- the [Sun SPARCstation IPC Recap writeup](/2017/07/24/ipc-recap) demonstrates how the images appear. The `bind_params` method takes care of handling both cases: it expects either `:files` and `:alt_texts` to be passed in, or automatically throws `:file` and `:alt_text` into single-element arrays.

The `internal_render` method loops over the supplied files, creating thumbnails linked to the full sized images. It can be called as such:

`{% raw %}{% linked_image :file => 'foo.jpg', :alt_text => 'bar baz' %}{% endraw %}`

and produces the output:

{% highlight html %}
{% linked_image :file => 'foo.jpg', :alt_text => 'bar baz' %}
{% endhighlight %}

Contact Form Links
------------------

The tag for inserting contact form links was created to centrailze configuration and reduce duplication. The contact form is currently part of [the rails_services project](https://github.com/glitchwrks/rails_services), but had previously been:

* a plain email address
* an obfuscated email address
* a link to a static page that did a `POST` to the [site_services app](https://github.com/chapmajs/site_services)

Changing it involved some find-and-replace against the site's source, as well as manual cleanup of missed links. With the contact tag, the mechanism is in one place, and only one file requires changing when the method of contact changes in the future. Here's the tag plugin:

{% codeblock :language => 'ruby', :title => '_plugins/contact_tag.rb' %}
require_relative 'glitchworks_tag'

class GlitchWorks::ContactTag < GlitchWorks::Tag
  
  def bind_params (params)
    @text = params[:text] || 'contact us'
  end

  def internal_render
    "<a href='https://services.theglitchworks.net/ng/messages/new'>#{@text}</a>"
  end
end

Liquid::Template.register_tag('contact', GlitchWorks::ContactTag)
{% endcodeblock %}

This tag is very simple, requiring only an optional `:text` parameter and otherwise rendering a static string. The text defaults to 'contact us,' the most common link text used before replacing Markdown links with the custom tag. Here's how it is called:

`{% raw %}{% contact :text => 'let me know' %}{% endraw %}`

and produces the output:

{% highlight html %}
{% contact :text => 'let me know' %}
{% endhighlight %}

Liquid Tag Blocks
-----------------

The next type of tag is the Liquid tag block, which is an element that requires an opening and closing tag. This is likely familiar to most Jekyll users in the `highlight` tag. Usage is covered in the [Liquid for Programmers](https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tag-blocks) documentation.

To make use of custom tag blocks, I introduced a new parent class, `GlitchWorks::Block`:

{% codeblock :language => 'ruby', :title => '_plugins/glitchworks_block.rb' %}
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
{% endcodeblock %}

The big difference here is that `GlitchWorks::Block` extends `Liquid::Block` rather than `Liquid::Tag`. The `initialize` method is handled in the same way; however, we must call `super` in the `render` method to get the text contained in the tag block. Our parent class assigns the contents of the tag block to the instance variable `@text`, for later use in tag block plugins.

Text Block Tag
--------------

The textblock tag is currently the simplest tag block implementation in the project. It simply wraps text in `<pre>` tags and puts a `<div>` with CSS decoration around it. This is to set the text apart from the rest of the document, providing the visual clue that it is effectively its own subdocument. Here's the implementation:

{% codeblock :language => 'ruby', :title => '_plugins/text_block.rb' %}
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
{% endcodeblock %}

No mystery here, the `:title` parameter is assigned in `bind_params`, and the `@text` instance variable is set in the parent class's `render` method. It can be called like this:

```
{% raw %}{% textblock :title => 'a block of text' %}{% endraw %}
some plain text
    whitespace preserved
{% raw %}{% endtextblock %}{% endraw %}
```

and produces the output:

{% highlight html %}
{% textblock :title => 'a block of text' %}
some plain text
    whitespace preserved
{% endtextblock %}
{% endhighlight %}

The Danger Block
----------------

A few writeups have warnings at the top of the article concerning [Bad Things](http://www.catb.org/jargon/html/B/Bad-Thing.html) that may happen if you just use examples from the article without understanding what's going on. Articles that use it include [the EPROM timer](/2016/03/21/eprom-timer), in which the computer is put in charge of mains power, and [Removing Cookies and Sessions from Rails 5](/2017/01/16/removing-cookies-sessions-rails-5), which may make your Rails app less secure if you don't know why you're disabling cookies and/or sessions.

This warning was previously achieved with HTML inlined in the Markdown template for the article, which was suboptimal. Not only was there plain HTML present, but Markdown couldn't be used within the HTML tags, meaning the link to [Bad Thing in the Jargon File](http://www.catb.org/jargon/html/B/Bad-Thing.html) had to be done as an anchor tag. The custom tag block is implemented as follows:

{% codeblock :language => 'ruby', :title => '_plugins/danger_block.rb' %}
class GlitchWorks::DangerBlock < GlitchWorks::Block

  def bind_params (params)
    @add_break = params[:add_break]
  end

  def internal_render
    <<~DANGER
    #{"<div>&nbsp;</div>" if @add_break}
    <div class='error_explanation'>
      <div class='error_explanation_content'>
        <p>
          #{markdown_converter.convert(@text)}
        </p>
      </div>
    </div>
    DANGER
  end
end

Liquid::Template.register_tag('danger', GlitchWorks::DangerBlock)
{% endcodeblock %}

The danger block tag makes use of the LoD accessor `markdown_converter`, which is defined in `GlitchWorks::Base`. It passes the contents of the block, assigned to `@text`, into the generator and displays it in a styled `<div>` to draw attention to the warning it contains. There's an optional `:add_break` parameter, which just inserts an unstyled `<div>` with a non-breaking space. This is necessary to add a bit of space between the warning if it immediately follows the header in a writeup. Here's an example of its use:

```
{% raw %}{% danger %}{% endraw %}
Don't even *think* about putting a fork in the receptacle!
{% raw %}{% enddanger %}{% endraw %}
```

It generates the following HTML:

{% highlight html %}
{% danger %}
Don't even *think* about putting a fork in the receptacle!
{% enddanger %}
{% endhighlight %}

Code Block Tag: an Extension of Jekyll's Highlight Tag
------------------------------------------------------

The codeblock tag is a direct extension of Jekyll's `highlight` tag, and as such it does not inherit from any of the parent classes or include the base module described above. In that sense, it's one of the more straightforward tag blocks to examine:

{% codeblock :language => 'ruby', :title => '_plugins/code_block.rb' %}
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
{% endcodeblock %}

As you can see, this class duplicates some of the code from `GlitchWorks::Base` and `GlitchWorks::Block`, but there's enough difference in what's going on that it didn't make sense to genericize the code any further. It is, after all, extending a completely different parent class!

Jekyll's `highlight` tag requires that a language be passed in, it takes it as the second argument to `initialize` via a regex. Simply passing in the contents of the `:language` parameter when calling `super` takes care of that. Since ths is a required parameter, we raise a `SyntaxError` in `bind_params` if it is not supplied.

Clearly used throughout this document, the codeblock tag block is invoked as such:

```
{% raw %}{% codeblock :language => 'ruby', :title => 'A Ruby Example' %}{% endraw %}
puts self.inspect
{% raw %}{% endcodeblock %}{% endraw %}
```
The HTML is generates is preformatted with many style wrappers, so the output won't be shown inline here.

Summary
-------

Plugins are indeed a simple way to add new Liquid tags to Jekyll, thereby reducing code repition, centralizing configuration, and making Markdown more readable. Hopefully the examples above get you started on your way to writing your own plugins!

Of course, no exercise in code maintenance and refactoring is complete until it's turned into a complete [yak shave](http://catb.org/jargon/html/Y/yak-shaving.html). In writing this article, it was discovered that [Python Pygments](http://pygments.org/), a syntax highlighting library, was not correctly handling Ruby "squiggly heredoc," which was introduced in Ruby 2.3. Chasing down this bug resulted in a pull request on the [pygments.rb gem](https://github.com/tmm1/pygments.rb/pull/178), as well as a [patch](https://gist.github.com/chapmajs/ea78713bf457c47984bf1be70101696d) against the Pygments library and the Pygments SlackBuild!

{% counter :text => 'plugins created' %}
