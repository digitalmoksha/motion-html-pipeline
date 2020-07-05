# frozen_string_literal: true

require File.expand_path('../lib/motion-html-pipeline/pipeline/version.rb', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'motion-html-pipeline'
  spec.version       = MotionHTMLPipeline::Pipeline::VERSION
  spec.authors       = ['Ryan Tomayko', 'Jerry Cheung', 'Garen J. Torikian', 'Brett Walker']
  spec.email         = ['ryan@github.com', 'jerry@github.com', 'gjtorikian@gmail.com', 'github@digitalmoksha.com']
  spec.description   = 'GitHub HTML processing filters and utilities (RubyMotion version)'
  spec.summary       = 'Helpers for processing content through a chain of filters (RubyMotion version, ported from https://github.com/jch/html-pipeline)'
  spec.homepage      = 'https://github.com/digitalmoksha/motion-html-pipeline'
  spec.licenses      = ['MIT']

  spec.files         = Dir.glob('lib/**/*.rb')
  spec.files        << 'README.md'
  spec.test_files    = Dir.glob('spec/**/*.rb')
  spec.require_paths = ['lib']

  spec.add_dependency 'motion-cocoapods'

  spec.add_development_dependency 'motion-expect', '~> 2.0' # required for Travis build to work
end
