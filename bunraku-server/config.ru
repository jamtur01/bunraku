$:.unshift(File.expand_path(File.dirname(__FILE__) + '/lib/'))
$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'bunraku/server'
require 'bunraku/version'

use Rack::Static, :urls => ["/css", "/images"], :root => "public"

run Bunraku::Server::Application
