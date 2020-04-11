unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

require 'motion-cocoapods'

lib_dir_path = File.dirname(File.expand_path(__FILE__))
Motion::Project::App.setup do |app|
  app.files.unshift(Dir.glob(File.join(lib_dir_path, "motion-html-pipeline/**/*.rb")))

  app.pods do
    pod 'HTMLKit', '~> 3.1'
  end
end