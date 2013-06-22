#! /usr/bin/env ruby

#
# This is an example agent which generates synthetic data.
# A 1mHz (one cycle every 16 minutes) sin+1, cos+1 and sin+5 wave is generated,
# using the Unix epoch as the base.
#

require "rubygems"
require "bundler/setup"
require "net/http"
require "net/https"

require "newrelic_plugin"

module GraphiteAgent

  class Agent < NewRelic::Plugin::Agent::Base

    agent_guid "com.gingerlime.graphite.graphite"
    agent_version "1.0.1"
    agent_config_options :settings
    agent_human_labels("Graphite Agent") { "Graphite" }

    def poll_cycle
      settings['targets'].each do |target|
        res = get_graphite_data(settings['server'], target)
        next unless res
        metrics = JSON.load(res)
        puts metrics
        metrics.each do |metric|
          report_metric_data(metric, target)
        end
      end
    end

    def get_graphite_data(server, target)
      from = target.fetch('from', '-2min')

      uri = URI(URI.encode("#{server['url']}/render/?from=#{from}&target=#{target['target']}&format=json"))
      req = Net::HTTP::Get.new(uri)
      if server['username']
        req.basic_auth server['username'], server['password']
      end
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) {|http|
            http.request(req)
      }
      res.body
    end

    def report_metric_data(metric, target)
      name = metric.fetch('target', '')
      return if name.empty?
      datapoints = metric['datapoints']
      return if datapoints.empty? || datapoints.nil?
      value = datapoints.last[0]
      units = target.fetch('units', 'Units')
      prefix = target.fetch('prefix', '')
      reported_name = [prefix, name].join('/')
      report_metric reported_name, units, value
    end

  end

  #
  # Register this agent with the component.
  # The ExampleAgent is the name of the module that defines this
  # driver (the module must contain at least three classes - a
  # PollCycle, a Metric and an Agent class, as defined above).
  #
  NewRelic::Plugin::Setup.install_agent :graphite, GraphiteAgent

  #
  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
