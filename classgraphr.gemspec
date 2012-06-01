Gem::Specification.new do |s|
  s.name          = 'ClassGraphR'
  s.version       = '0.0.0'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Luke Andrew']
  s.email         = ['luke.classgraphr@la.id.au']
  s.summary       = 'Produce class dependency graphs of your Ruby code' 
  s.description   = 'Produce a class dependency graph by tracing the method calls of running code. The output is a .dot file for use with GraphViz'
  s.files         = Dir.glob('{test,lib}/**/*.rb') + %w(LICENSE-CC-BY-SA LICENSE-GPLv3 README.md)
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 1.9'
end
