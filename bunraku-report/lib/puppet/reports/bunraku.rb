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

require 'time'
require 'puppet'

begin
  require 'rest-client'
rescue LoadError
  Puppet.info "You need the `rest-client` gem to use the Bunraku report"
end

Puppet::Reports.register_report(:bunraku) do

    configfile = File.join([File.dirname(Puppet.settings[:config]), "bunraku.yaml"])
    raise(Puppet::ParseError, "Bunraku report config file #{configfile} not readable") unless File.exist?(configfile)
    config = YAML.load_file(configfile)
    STATUS_URL = config[:status_url] ||= 'http://localhost:4567/new'

    desc <<-DESC
    Send notification of the status reports to the Bunraku dashboard.  You will need to setup the Bunraku dashboard.
    DESC

    def process
      body = consume_report(self)
      post_body = body.to_json
      Puppet.debug "Sending report to Bunraku"
      response = RestClient.post STATUS_URL, {:data => post_body}, { :content_type => :json, :accept => :json }
    end

    def consume_report(report)
      metrics = extract_metrics(report)
      rep = construct_report(report,metrics)
      rep
    end

    def construct_report(report,metrics)
      rep = { :node              => report.host,
              :time              => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
              :status            => report.status,
              :kind              => report.kind,
              :puppet_version    => report.puppet_version,
              :metrics           => metrics }
    end

    def extract_metrics(report)
      metrics = {}
      stats = report.metrics
      stats.each { |metric,data|
        data.values.each { |v|
          metrics["#{v[0]} #{metric}"] = v[2] }
      }
      metrics
    end

    def extract_logs(report)
      logs = []
      report.logs.each { |log|
      logs << log
      }
      logs
    end
end
