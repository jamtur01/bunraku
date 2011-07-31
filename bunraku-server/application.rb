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
        $redis = Redis.new
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
          $redis.mget(*ids.map { |id| "node-#{id}" }).map { |raw| JSON.parse(raw) }
        end
      end

      def sort_nodes(nodes)
        if nodes.empty?
          []
        else
          nodes.sort_by { |node| node["time"] }.reverse!
        end
      end

      get '/' do
        nodes = load_nodes($redis.smembers("all-nodes").last(100))
        @sorted = sort_nodes(nodes)
        erb :index
      end

      get '/failed' do
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = nodes.select { |node| node["status"] == 'failed' }
        @sorted = sort_nodes(nodes)
        erb :failed
      end

      get '/unchanged' do
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = nodes.select { |node| node["status"] == 'unchanged' }
        @sorted = sort_nodes(nodes)
        redirect '/' if @sorted.empty?
        erb :unchanged
      end

      get '/successful' do
        nodes = load_nodes($redis.smembers("all-nodes"))
        nodes = nodes.select { |node| node["status"] == 'changed' }
        @sorted = sort_nodes(nodes)
        redirect '/' if @sorted.empty?
        erb :successful
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
