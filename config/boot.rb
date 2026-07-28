ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
ENV["LC_ALL"] ||= "en_US.UTF-8"
ENV["LANG"]   ||= "en_US.UTF-8"
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
