Gem::Specification.new do |s|
  s.name        = "easy_geometry"
  s.version     = "0.2.0"
  s.author      = ["Henry Metlov"]
  s.date        = '2019-10-20'
  s.homepage    = "https://github.com/Metloff/easy_geometry"
  s.description = "Geometric primitives and algorithms for Ruby"
  s.summary     = "Geometric primitives and algorithms for Ruby"
  s.license     = "MIT"

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
end