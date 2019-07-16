# motion-html-pipeline

[![Gem Version](https://badge.fury.io/rb/motion-html-pipeline.svg)](http://badge.fury.io/rb/motion-html-pipeline)
[![Build Status](https://travis-ci.org/digitalmoksha/motion-html-pipeline.svg?branch=master)](https://travis-ci.org/digitalmoksha/motion-html-pipeline)

_This gem is a port of the [`html-pipeline` gem](https://github.com/jch/html-pipeline) to RubyMotion, for use on iOS and macOS. Currently synced with `html-pipeline` release [`v.2.11.0`](https://github.com/jch/html-pipeline/releases/tag/v2.11.0)_

GitHub HTML processing filters and utilities. This module includes a small
framework for defining DOM based content filters and applying them to user
provided content. Read an introduction about this project in
[this blog post](https://github.com/blog/1311-html-pipeline-chainable-content-filters).

- [Installation](#installation)
- [Usage](#usage)
  - [Examples](#examples)
- [Filters](#filters)
  - [Disabled Filters](#disabled-filters)
- [Documentation](#documentation)
- [Extending](#extending)
  - [3rd Party Extensions](#3rd-party-extensions)
- [Instrumenting](#instrumenting)
- [Contributing](#contributing)
  - [Contributors](#contributors)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'motion-html-pipeline'
```

and to your `Rakefile`

```ruby
require 'motion-html-pipeline'
```

And then execute:

```sh
$ bundle
```

## Usage

This library provides a handful of chain-able HTML filters to transform user
content into markup. A filter takes an HTML string or a
`MotionHTMLPipeline::DocumentFragment`, optionally manipulates it, and then
outputs the result.

For example, to transform an image URL into an image tag:

```ruby
filter = MotionHTMLPipeline::Pipeline::ImageFilter.new("http://example.com/test.jpg")
filter.call
```

would output

```html
<img src="http://example.com/test.jpg" alt=""/>
```

Filters can be combined into a pipeline which causes each filter to hand its
output to the next filter's input. So if you wanted to have content be
filtered through the `ImageFilter` and then wrap it in an `<a>` tag with 
a max-width inline style:

```ruby
pipeline = MotionHTMLPipeline::Pipeline.new([
  MotionHTMLPipeline::Pipeline::ImageFilter,
  MotionHTMLPipeline::Pipeline::ImageMaxWidthFilter
])
result = pipeline.call("http://example.com/test.jpg")
result[:output].to_s
```

Prints:

```html
<a href="http://example.com/test.jpg" target="_blank"><img src="http://example.com/test.jpg" alt="" style="max-width:100%;"></a>
```

Some filters take an optional **context** and/or **result** hash. These are
used to pass around arguments and metadata between filters in a pipeline. For
example, with the `AbsoluteSourceFilter` you can pass in `:image_base_url` in
the context hash:


```ruby
filter = MotionHTMLPipeline::Pipeline::AbsoluteSourceFilter.new('<img src="/test.jpg">', image_base_url: 'http://example.com')
filter.call
```

### Examples

We define different pipelines for different parts of our app. Here are a few
paraphrased snippets to get you started.

_Note: these are examples from the original
gem since they illustrate how the pipelines can be used.  Many of the filters are
not currently usable yet, as mentioned in the Filters section below._

```ruby
# The context hash is how you pass options between different filters.
# See individual filter source for explanation of options.
context = {
  :asset_root => "http://your-domain.com/where/your/images/live/icons",
  :base_url   => "http://your-domain.com"
}

# Pipeline providing sanitization and image hijacking but no mention
# related features.
SimplePipeline = Pipeline.new [
  SanitizationFilter,
  TableOfContentsFilter, # add 'name' anchors to all headers and generate toc list
  CamoFilter,
  ImageMaxWidthFilter,
  SyntaxHighlightFilter,
  EmojiFilter,
  AutolinkFilter
], context

# Pipeline used for user provided content on the web
MarkdownPipeline = Pipeline.new [
  MarkdownFilter,
  SanitizationFilter,
  CamoFilter,
  ImageMaxWidthFilter,
  HttpsFilter,
  MentionFilter,
  EmojiFilter,
  SyntaxHighlightFilter
], context.merge(:gfm => true) # enable github formatted markdown


# Define a pipeline based on another pipeline's filters
NonGFMMarkdownPipeline = Pipeline.new(MarkdownPipeline.filters,
  context.merge(:gfm => false))

# Pipelines aren't limited to the web. You can use them for email
# processing also.
HtmlEmailPipeline = Pipeline.new [
  PlainTextInputFilter,
  ImageMaxWidthFilter
], {}

# Just emoji.
EmojiPipeline = Pipeline.new [
  PlainTextInputFilter,
  EmojiFilter
], context
```

## Filters

* `AbsoluteSourceFilter` - replace relative image urls with fully qualified versions
* `HttpsFilter` - HTML Filter for replacing http github urls with https versions.
* `ImageMaxWidthFilter` - link to full size image for large images

### Disabled Filters

Several of the standard filters, such as `AutolinkFilter` and `EmojiFilter`, are initially disabled, as they rely on other Ruby gems that don't have RubyMotion equivalents.  Please feel free to submit a pull request that enables any of them.

* `MentionFilter` - replace `@user` mentions with links
* `AutolinkFilter` - auto_linking urls in HTML
* `CamoFilter` - replace http image urls with [camo-fied](https://github.com/atmos/camo) https versions
* `EmailReplyFilter` - util filter for working with emails
* `EmojiFilter` - everyone loves [emoji](http://www.emoji-cheat-sheet.com/)!
* `MarkdownFilter` - convert markdown to html
* `PlainTextInputFilter` - html escape text and wrap the result in a div
* `SanitizationFilter` - whitelist sanitize user markup
* `SyntaxHighlightFilter` - code syntax highlighter
* `TableOfContentsFilter` - anchor headings with name attributes and generate Table of Contents html unordered list linking headings

## Documentation

Full reference documentation for the original `html-pipeline` gem can be [found here](http://rubydoc.info/gems/html-pipeline/frames).

## Extending

To write a custom filter, you need a class with a `call` method that inherits
from `MotionHTMLPipeline::Pipeline::Filter`.

For example this filter adds a base url to images that are root relative:

```ruby
class RootRelativeFilter < MotionHTMLPipeline::Pipeline::Filter

  def call
    doc.css("img").each do |img|
      next if img['src'].nil?

      src = img['src'].strip

      if src.start_with? '/'
        base_url   = NSURL.URLWithString(context[:base_url])
        img["src"] = NSURL.URLWithString(src, relativeToURL: base_url).absoluteString
      end
    end

    doc
  end

end
```

Now this filter can be used in a pipeline:

```ruby
Pipeline.new [ RootRelativeFilter ], { base_url: 'http://somehost.com' }
```

We use [HTMLKit](https://github.com/iabudiab/HTMLKit) for document parsing in `MotionHTMLPipeline::DocumentFragment`.

### 3rd Party Extensions

Many people have built their own filters for [html-pipeline](https://github.com/jch/html-pipeline/issues).  Although these have not been converted to run with RubyMotion, most of them should be easy convert.

Here are some extensions people have built:

* [html-pipeline-asciidoc_filter](https://github.com/asciidoctor/html-pipeline-asciidoc_filter)
* [jekyll-html-pipeline](https://github.com/gjtorikian/jekyll-html-pipeline)
* [nanoc-html-pipeline](https://github.com/burnto/nanoc-html-pipeline)
* [html-pipeline-bitly](https://github.com/dewski/html-pipeline-bitly)
* [html-pipeline-cite](https://github.com/lifted-studios/html-pipeline-cite)
* [tilt-html-pipeline](https://github.com/bradgessler/tilt-html-pipeline)
* [html-pipeline-wiki-link'](https://github.com/lifted-studios/html-pipeline-wiki-link) - WikiMedia-style wiki links
* [task_list](https://github.com/github/task_list) - GitHub flavor Markdown Task List
* [html-pipeline-nico_link](https://github.com/rutan/html-pipeline-nico_link) - An HTML::Pipeline filter for [niconico](http://www.nicovideo.jp) description links
* [html-pipeline-gitlab](https://gitlab.com/gitlab-org/html-pipeline-gitlab) - This gem implements various filters for html-pipeline used by GitLab
* [html-pipeline-youtube](https://github.com/st0012/html-pipeline-youtube) - An HTML::Pipeline filter for YouTube links
* [html-pipeline-flickr](https://github.com/st0012/html-pipeline-flickr) - An HTML::Pipeline filter for Flickr links
* [html-pipeline-vimeo](https://github.com/dlackty/html-pipeline-vimeo) - An HTML::Pipeline filter for Vimeo links
* [html-pipeline-hashtag](https://github.com/mr-dxdy/html-pipeline-hashtag) - An HTML::Pipeline filter for hashtags
* [html-pipeline-linkify_github](https://github.com/jollygoodcode/html-pipeline-linkify_github) - An HTML::Pipeline filter to autolink GitHub urls
* [html-pipeline-redcarpet_filter](https://github.com/bmikol/html-pipeline-redcarpet_filter) - Render Markdown source text into Markdown HTML using Redcarpet
* [html-pipeline-typogruby_filter](https://github.com/bmikol/html-pipeline-typogruby_filter) - Add Typogruby text filters to your HTML::Pipeline
* [korgi](https://github.com/jodeci/korgi) - HTML::Pipeline filters for links to Rails resources


## Instrumenting

_Although instrumenting was ported, it has not been used real-world, and may not work 
properly at this time._

Filters and Pipelines can be set up to be instrumented when called. The pipeline
must be setup with an
[ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html)
compatible service object and a name. New pipeline objects will default to the
`MotionHTMLPipeline::Pipeline.default_instrumentation_service` object.

``` ruby
# the AS::Notifications-compatible service object
service = ActiveSupport::Notifications

# instrument a specific pipeline
pipeline = MotionHTMLPipeline::Pipeline.new [MarkdownFilter], context
pipeline.setup_instrumentation "MarkdownPipeline", service

# or set default instrumentation service for all new pipelines
MotionHTMLPipeline::Pipeline.default_instrumentation_service = service
pipeline = HTML::Pipeline.new [MarkdownFilter], context
pipeline.setup_instrumentation "MarkdownPipeline"
```

Filters are instrumented when they are run through the pipeline. A
`call_filter.html_pipeline` event is published once the filter finishes. The
`payload` should include the `filter` name. Each filter will trigger its own
instrumentation call.

``` ruby
service.subscribe "call_filter.html_pipeline" do |event, start, ending, transaction_id, payload|
  payload[:pipeline] #=> "MarkdownPipeline", set with `setup_instrumentation`
  payload[:filter] #=> "MarkdownFilter"
  payload[:context] #=> context Hash
  payload[:result] #=> instance of result class
  payload[:result][:output] #=> output HTML String or Nokogiri::DocumentFragment
end
```

The full pipeline is also instrumented:

``` ruby
service.subscribe "call_pipeline.html_pipeline" do |event, start, ending, transaction_id, payload|
  payload[:pipeline] #=> "MarkdownPipeline", set with `setup_instrumentation`
  payload[:filters] #=> ["MarkdownFilter"]
  payload[:doc] #=> HTML String or Nokogiri::DocumentFragment
  payload[:context] #=> context Hash
  payload[:result] #=> instance of result class
  payload[:result][:output] #=> output HTML String or Nokogiri::DocumentFragment
end
```

## FAQ

_I have left this FAQ item here for when we get the `PlainTextInputFilter` working._

### 1. Why doesn't my pipeline work when there's no root element in the document?

To make a pipeline work on a plain text document, put the `PlainTextInputFilter`
at the beginning of your pipeline. This will wrap the content in a `div` so the
filters have a root element to work with. If you're passing in an HTML fragment,
but it doesn't have a root element, you can wrap the content in a `div`
yourself. For example:

```ruby
EmojiPipeline = Pipeline.new [
  PlainTextInputFilter,  # <- Wraps input in a div and escapes html tags
  EmojiFilter
], context

plain_text = "Gutentag! :wave:"
EmojiPipeline.call(plain_text)

html_fragment = "This is outside of an html element, but <strong>this isn't. :+1:</strong>"
EmojiPipeline.call("<div>#{html_fragment}</div>") # <- Wrap your own html fragments to avoid escaping
```

## Contributing

### Contributors

Thanks to all of [these contributors](https://github.com/jch/html-pipeline/graphs/contributors), who have made the original gem possible.
