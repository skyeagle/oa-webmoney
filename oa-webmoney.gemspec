# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oa-webmoney/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Anton Orel"]
  gem.email         = ["eagle.anton@gmail.com"]
  gem.description   = %q{OmniAuth Webmoney Strategy}
  gem.summary       = %q{OmniAuth Webmoney Strategy}
  gem.homepage      = %q{http://github.com/skyeagle/oa-webmoney}

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "oa-webmoney"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Webmoney::VERSION

  gem.add_runtime_dependency 'webmoney', ['~> 0.0.12']
  gem.add_development_dependency 'bundler', ["~> 1.1.rc.2"]
end
