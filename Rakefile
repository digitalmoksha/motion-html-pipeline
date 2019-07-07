$:.unshift("/Library/RubyMotion/lib")

platform = ENV.fetch('platform', 'osx')
testing  = true if ARGV.join(' ') =~ /spec/

require "motion/project/template/#{platform}"
require 'rubygems'

begin
  require 'bundler'
  testing ? Bundler.require(:default, :spec) : Bundler.require
  require 'motion/project/template/gem/gem_tasks'
rescue LoadError
end

require 'motion-expect' if testing

Motion::Project::App.setup do |app|
  app.name        = 'motion-html-pipeline'
  app.identifier  = 'com.motion-gemtest.motion-html-pipeline'

  app.detect_dependencies = true
end
