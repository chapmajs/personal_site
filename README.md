# glitchwrks.com Source

This project contains the source, configuration, et c. use with [Jekyll](https://jekyllrb.com/) to generate [glitchwrks.com](http://www.glitchwrks.com/). The Jekyll site is completely static, but does make use of several dynamic projects:

* [site_services](https://github.com/chapmajs/site_services) -- Sinatra app that provides hit counter services
* [rails_services](https://github.com/glitchwrks/rails_services) -- Rails app that provides many dynamic functions, such as the contact form

### Plugins

There are a number of custom plugins found in [the _plugins directory](https://github.com/glitchwrks/glitchwrks.com/tree/master/_plugins). These include:

* `codeblock` formats blocks of source code, extends Jekyll's built-in `highlight` block
* `textblock` formats blocks of fixed width plaintext
* `counter` generates a JavaScript include for counters from [site_services](https://github.com/chapmajs/site_services) -- Sinatra app that provides hit counter services
* `danger` generates an attention-getting notice on the page
* `linked_image` places one or more image thumbnails on the page, with links to high-res versions

See some of the files in [the _posts directory](https://github.com/glitchwrks/glitchwrks.com/tree/master/_posts) for the usage of these plugins.