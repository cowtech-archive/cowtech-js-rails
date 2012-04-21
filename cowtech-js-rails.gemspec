
# encoding: utf-8
#
# This file is part of the cowtech-js-rails gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "./lib/cowtech_js/version"

Gem::Specification.new do |s|
	s.name = "cowtech-js-rails"
	s.version = CowtechJS::Version::STRING
	s.authors = ["Shogun"]
	s.email = ["shogun_panda@me.com"]
	s.homepage = "http://github.com/ShogunPanda/cowtech-js-rails"
	s.summary = %q{A set of Javascript libraries.}
	s.description = %q{A set of Javascript libraries.}

	s.rubyforge_project = "cowtech-js-rails"
	s.files = `git ls-files`.split("\n")
	s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ["lib", "vendor"]

	s.required_ruby_version = ">= 1.9.2"
	s.add_dependency("coffee-script", "~> 2.0")
	s.add_dependency("rails", "~> 3.2.0")
	s.add_dependency("sprockets", "~> 2.0")
end