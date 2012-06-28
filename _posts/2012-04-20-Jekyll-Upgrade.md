---
layout: post
title: New Static Site Layout with Jekyll
topic: Using the static site generator Jekyll to ease maintenance
category: news
description: I finally finished rewriting the site using Jekyll, a blog-aware static site generator written in Ruby. Although the process required reformatting all existing site content, the move appears to have been well worth it! Expect a higher frequency of updates now that writing an article only involves creating a textfile and executing a script.
image: glitch.jpg
---

If you've been wondering where site updates have been hiding and why it's taken me so long to write up more recent projects, it's because I've been in the process of completely restructuring the Glitch Works website. The static HTML was getting too cumbersome to maintain, even with scripts to go through and update links. On the suggestion of [Ryan Lewis](https://github.com/c00lryguy), I investigated moving to Jekyll, a blog-aware static site generator. For those unfamiliar with Jekyll, here's a bit from their [github README](https://github.com/mojombo/jekyll/blob/master/README.textile):

>Jekyll is a simple, blog aware, static site generator. It takes a template directory (representing the raw form of a website), runs it through Textile or Markdown and Liquid converters, and spits out a complete, static website suitable for serving with Apache or your favorite web server. This is also the engine behind GitHub Pages, which you can use to host your project�s page or blog right here from GitHub.

Essentially, it's a site generator written in Ruby that allows you to define templates that can generate page indexes given a directory full of posts. After you build your index templates, you simply add posts, run the generator, and upload the results. Jekyll includes a server mode, which allows preview of the generated content on your local machine -- handy if you have an upload that will take a while due to binary content like large images. And, even though you end up with a content management system that feels very dynamic, you get to keep the security and compatibility of static HTML.

So, that's what I've been up to since the last article concerning my IO-2 board was written. Enjoy, and keep an eye out for an actual guide to getting started with Jekyll under Linux in the near future!
