# frozen_string_literal: true

# Gives a Nokogiri type of interface, but uses
# HTMLKit (https://github.com/iabudiab/HTMLKit)
#
# Not meant to duplicate Nokogiri completely, just add a similar interface
#------------------------------------------------------------------------------
module MotionHTMLPipeline
  class DocumentFragment
    attr_reader :document

    def self.parse(html)
      DocumentFragment.new(html)
    end

    def initialize(html)
      @document = HTMLDocument.documentWithString(html)
    end

    def css(query)
      document.querySelectorAll(query)
    end

    def to_html
      document.body.innerHTML
    end
    alias to_s to_html
  end
end
