# users.glitchwrks.com/~glitch/ Source

This project contains the source, configuration, et c. use with [Jekyll](https://jekyllrb.com/) to generate [my personal site](http://user.glitchwrks.com/~glitch/). The Jekyll site is completely static, but does make use of several dynamic projects:

* [site_services](https://github.com/chapmajs/site_services) -- Sinatra app that provides hit counter services
* [rails_services](https://github.com/glitchwrks/rails_services) -- Rails app that provides many dynamic functions, such as the contact form

### Plugins

There are a number of custom plugins found in [the _plugins directory](https://github.com/chapmajs/personal_site/tree/master/_plugins). These include:

* `codeblock` formats blocks of source code, extends Jekyll's built-in `highlight` block
* `textblock` formats blocks of fixed width plaintext
* `counter` generates a JavaScript include for counters from [site_services](https://github.com/chapmajs/site_services) -- Sinatra app that provides hit counter services
* `danger` generates an attention-getting notice on the page
* `linked_image` places one or more image thumbnails on the page, with links to high-res versions
* `contact` puts a contact form link in, defaulting to "contact us" for link text

See some of the files in [the _posts directory](https://github.com/chapmajs/personal_site/tree/master/_posts) for the usage of these plugins.

### `_upload.sh.example`

This is the short shell script that uses `rsync` to keep glitchwrks.com updated with the code Jekyll generates. It should work with most UNIX-like operating systems, and currently deploys to an OpenBSD machine.

### Development Environment

I mostly use this project under [Slackware Linux 15](http://www.slackware.com) with [RVM](https://rvm.io) for Ruby version management and [bundler](https://bundler.io) for gemset management. Current development Ruby is MRI `3.1.2p20`.

Since the generated site is static, none of the development dependencies are required on the production server.