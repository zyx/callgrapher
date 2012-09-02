Gem::Specification.new do |s|
  s.name          = 'callgrapher'
  s.version       = '0.0.1'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Luke Andrew']
  s.email         = ['luke.callgrapher@la.id.au']
  s.summary       = 'Produce call graphs of your Ruby code' 
  s.description   = 'Produce a call graph graph by tracing the method calls of running code. The output is a .dot file for use with GraphViz'
  s.files         = %w(lib/callgrapher.rb test/test.rb LICENSE-CC-BY-SA LICENSE-GPLv3 README.md)
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 1.9'
end
