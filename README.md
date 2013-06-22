# graphite-newrelic

A Graphite plugin for New Relic (beta / proof-of-concept)

Get your graphite data displayed in New Relic.

## Why?

Because it's there.
New Relic has a very nice charting capabilities.
Unfortunately it's not that easy to work with custom/business-data as Graphite/Statsd.
The new Plugin options for New Relic make it somehow possible to try to mix those two together.

## Usage

* Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
* Update your settings to match your graphite server, authentication (optional)
* Update the targets to match your graphite targets
* run `bundle install` and then `bundle exec ./graphite_agent.rb`
* keep your fingers-crossed

## Notes / Settings

This is still in the proof-of-concept phase. Just a weekend project at this stage. It seems to work though.

Only the **last datapoint** is currently used from graphite. If you are trying to collect counters, this might mean you won't get the data you expect. Use graphite's `summary` or other aggregation functions, and make sure the last datapoint is correct. I might extent it in future to pick between last/first/average/min/max etc.

The New Relic Ruby SDK does not seem to support any kind of aggregation (total, max, min etc are all the same). see https://github.com/newrelic-platform/newrelic_plugin/blob/master/lib/newrelic_plugin/data_collector.rb#L14

By default this agent will attempt to fetch 2 minutes of data from graphite. You can adjust this using the `from` parameter in your `target`.

New Relic limits the number of updates to 1 per minute. The polling interval is also set to 60 seconds by default.

Once you run the agent, it will report data to your new relic account. You will have to set up the dashboard(s) to show the data. The `prefix` setting in your `target` can be used to organize data sent to New Relic.

Each `target` can report different `units` (e.g. `req/s`, `registration`, `clicks`). Without it, the agent will default to `Units`.

It's recommended to use the graphite `alias`, `aliasByNode` etc - to make the targets look nicer on New Relic.

I couldn't find a way to *delete* the plugin from New Relic once it starts reporting data.

## Contributions

I'd be happy to get some ideas or pull requests and think of ways to improve this. 

It might make more sense to create a New Relic plugin that acts as a statsd server. This could fit better within the New Relic plugin model, and would require no Graphite server. However, the New Relic plugin model is based on polling, so I'm not sure how to mix those two together. Using New Relic as a statsd backend might also lose some of the nice capabilities of Graphite to aggregate data in different ways.
