$:.unshift(File.expand_path(File.dirname(__FILE__) + '/lib/'))
$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'bunraku/server'

run Bunraku::Server::Application
