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

require 'restclient'
require 'time'
require 'puppet'

Puppet::Reports.register_report(:bunraku) do

    configfile = File.join([File.dirname(Puppet.settings[:config]), "bunraku.yaml"])
    raise(Puppet::ParseError, "Bunraku report config file #{configfile} not readable") unless File.exist?(configfile)
    config = YAML.load_file(configfile)
    STATUS_URL = config[:status_url]

    desc <<-DESC
    Send notification of the status reports to the Bunraku dashboard.  You will need to setup the Bunraku dashboard.
    DESC

    def process

      STATUS_URL = 'http://localhost:9292/new'

      rep = consume_report(self)
      post_body = rep.to_json
      Puppet.debug "Sending report to Bunraku"
      response = RestClient.post STATUS_URL, {:data => post_body}, { :content_type => :json, :accept => :json }
    end

    def consume_report(report)
      extract_node_info(report)
      extract_status(report)
      extract_time(report)
      rep = construct_report
      rep
    end

    def construct_report
      rep = { :node              => @node,
              :success           => success?,
              :time              => @time,
              :status            => @status }
    end

    def success?
      @status != 'failed'
    end

    def extract_node_info(report)
      @node = report.host
    end

    def extract_status(report)
      @status = report.status
    end

    def extract_time(report)
      @time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end
end
