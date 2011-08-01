$:.unshift(File.dirname(__FILE__) + '/lib')
require 'bunraku/version'

Gem::Specification.new do |s|
  s.name = 'bunraku-server'
  s.version = Bunraku::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "A Puppet status panel."
  s.description = s.summary
  s.author = "James Turnbull"
  s.email = "james@lovedthanlost.net"
  s.homepage = "http://github.com/jamtur01/bunraku"

  s.add_dependency "sinatra",
  s.add_dependency "redis",
  s.add_dependency "json",
  s.add_dependency "vegas",

  s.bindir       = "bin"
  s.executables  = %w( bunraku-server )
  s.require_path = 'lib'
end
