# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "squirrel_crawler"
  s.version     = "1.0"
  s.authors     = ["Alex Sinishin"]
  s.email       = ["sinishin@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Another scraper}
  s.description = %q{Nobel laureats scraping}

  s.rubyforge_project = "squirrel_crawler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"

  s.add_runtime_dependency     "lego",   :git => 'git://github.com/asinishin/lego.git'
  s.add_runtime_dependency     "lego_k", :git => 'git://github.com/asinishin/lego_k.git'
end
