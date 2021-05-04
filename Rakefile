# frozen_string_literal: true

$LOAD_PATH.unshift('/Library/RubyMotion/lib')
$LOAD_PATH.unshift('~/.rubymotion/rubymotion-templates')

platform = ENV.fetch('platform', 'osx')
testing  = true if ARGV.join(' ') =~ /spec/

require "motion/project/template/#{platform}"
require 'rubygems'

raise 'export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES' unless ENV['OBJC_DISABLE_INITIALIZE_FORK_SAFETY'] == 'YES'

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

  if platform == 'ios'
    # must set to the maximum SDK that the open source license supports,
    # which is the latest non-beta
    app.sdk_version           = '13.5'
    app.deployment_target     = '13.5'
  else
    app.sdk_version           = '11.1'
    app.deployment_target     = '11.1'
  end

  app.detect_dependencies = true
end
