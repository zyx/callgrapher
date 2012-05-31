Gem::Specification.new do |s|
  s.name          = 'ClassGraphR'
  s.version       = '0.0.0'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Luke Andrew']
  s.email         = ['luke.classgraphr@la.id.au']
  s.summary       = 'Produce class dependency graphs of your Ruby code' 
  s.files         = Dir.glob '{test,lib}/**/*.rb'
  s.require_paths = 'lib'
end
