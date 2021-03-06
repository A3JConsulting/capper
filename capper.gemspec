# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "a3j-capper"
  s.version = "2.0.0"
  s.authors = ["Joel Bonander"]
  s.email = ["jb@a3j.se"]
  s.homepage = "http://github.com/A3JConsulting/capper"
  s.summary = %q{Capper is a collection of opinionated Capistrano recipes}
  s.description = %q{Capper is a collection of opinionated Capistrano recipes}

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]

  s.add_dependency "erubis"
  s.add_dependency "dedent"
  s.add_dependency "capistrano"
  s.add_dependency "capistrano_colors"
  s.add_dependency "rvm-capistrano"
end
