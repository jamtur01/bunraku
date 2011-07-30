#--
# Author:: James Turnbull (<james@lovedthanlost.net>)
# Copyright:: Copyright (c) 2011 James Turnbull
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'redis'
require 'json'

module Bunraku
  module Server
    class Application < Sinatra::Base

      configure do
        puts "Connecting to Redis"
        $redis = Redis.new
      end

      def load_nodes(ids)
        if ids.empty?
          []
        else
          $redis.mget(*ids.map { |id| "node-#{id}" }).map { |raw| JSON.parse(raw) }
        end
      end

      get '/' do
        @nodes = load_nodes($redis.smembers("all-nodes").last(100))
        @sorted = @nodes.sort_by { |node| node["time"] }.reverse!
        erb :index
      end

      post '/new/?' do
        node_id = $redis.incr(:node_counter)

        node = params[:data]

        $redis.set("node-#{node_id}", node)
        $redis.sadd("all-nodes", node_id)
      end
    end
  end
end
