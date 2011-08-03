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

      def get_title(path)
        path.gsub(/^\//, '').capitalize
      end

      def load_nodes(ids)
        if ids.empty?
          []
        else
          nodes = []
          ids.each { |id|
            node = $redis.hgetall("node-#{id}")
            nodes << node
          }
          nodes
        end
      end

      def load_node(id)
        if id.nil?
          return "No node found"
        else
          @detail = $redis.hgetall("node-#{id}")
          @metrics = $redis.hgetall("node-#{id}:metrics")
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
        @title = nil
        nodes = load_nodes($redis.smembers("all-nodes").last(100))
        @sorted = sort_nodes(nodes)
        erb :index
      end

      get '/failed' do
        @title = get_title(request.path_info)
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'status','failed')
        @sorted = sort_nodes(nodes)
        erb :index
      end

      get '/unchanged' do
        @title = get_title(request.path_info)
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'status','unchanged')
        @sorted = sort_nodes(nodes)
        redirect '/' if @sorted.empty?
        erb :index
      end

      get '/changed' do
        @title = get_title(request.path_info)
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'status','changed')
        @sorted = sort_nodes(nodes)
        redirect '/' if @sorted.empty?
        erb :index
      end

      get '/node/:node' do |node|
        @node = params[:node]
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = select_node(nodes,'node',node)
        @sorted = sort_nodes(nodes)
        erb :node
      end

      get '/node/detail/:id' do |id|
        id = params[:id]
        load_node(id)
        erb :detail
      end

      post '/new/?' do
        id = $redis.incr(:node_counter)

        node = JSON.parse(params[:data])

        node.each { |type,value|
          if type == 'metrics'
            value.each { |n,d|
              $redis.hset("node-#{id}:#{type}", n, d)
            }
          else
            $redis.hset("node-#{id}", type, value)
          end
        }
        $redis.hset("node-#{id}", "id", id)
        $redis.sadd("all-nodes", id)
      end
    end
  end
end
