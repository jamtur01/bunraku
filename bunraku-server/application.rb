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
require 'pp'

module Bunraku
  module Server
    class Application < Sinatra::Base

      configure do
        set :static, true
        set :root, File.dirname(__FILE__)
        set :public, 'public'
        set :redis_server, 'localhost'
        set :redis_port, 6379
        $redis = Redis.new(:host => settings.redis_server, :port => settings.redis_port)
      end

      helpers do
        def cycle
          %w{even odd}[@_cycle = ((@_cycle || -1) + 1) % 2]
        end

        CYCLE = %w{even odd}
        def cycle_fully_sick
          CYCLE[@_cycle = ((@_cycle || -1) + 1) % 2]
        end
      end

      def load_nodes(ids)
        if ids.empty?
          []
        else
          nodes = []
          ids.each { |id| 
            node = $redis.hgetall("node-#{id}")
            node["id"] = id
            nodes << node
          }
          nodes
        end
      end

      def sort_nodes(nodes)
        if nodes.empty?
          []
        else
          nodes.sort_by { |node| node["time"] }.reverse!
        end
      end

      def select_node(nodes,query,value)
        nodes.select { |node| node[query] == value }
      end

      get '/' do
        nodes = load_nodes($redis.smembers("all-nodes").last(100))
        @sorted = sort_nodes(nodes)
        erb :index
      end

      get '/failed' do
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'status','failed')
        @sorted = sort_nodes(nodes)
        erb :failed
      end

      get '/unchanged' do
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'status','unchanged')
        @sorted = sort_nodes(nodes)
        redirect '/' if @sorted.empty?
        erb :unchanged
      end

      get '/successful' do
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'status','changed')
        @sorted = sort_nodes(nodes)
        redirect '/' if @sorted.empty?
        erb :successful
      end

      get '/node/:node' do |node|
        @node = params[:node]
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'node',node)
        @sorted = sort_nodes(nodes)
        erb :node
      end

      post '/new/?' do
        node_id = $redis.incr(:node_counter)

        node = JSON.parse(params[:data])

        node.each { |type,value|
          $redis.hset("node-#{node_id}", type, value)
        }
        $redis.sadd("all-nodes", node_id)
      end
    end
  end
end
