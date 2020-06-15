#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'optparse'
require 'active_support/inflector'
require 'dotenv/load'
require 'rest-client'
require 'gitlab'

require_relative 'utilities'
require_relative 'wall_socket'
require_relative 'jenkins'
require_relative 'gitlab'

class Ampel
  include Utilities
  include WallSocket
  include Jenkins
  include Gitlab

  def run(options)
    if !is_healthy?
      message = "ALERT: Automation server is not responding! Switching to alarm state. :-("

      toggle_green_light(false, options)
      toggle_red_light(true, options)
      send_slack_message(options, message)

      puts message
    elsif failed_jobs_or_pipelines == 0
      message = "OK: Everything is fine again! Green light is on. :-)"

      toggle_green_light(true, options)
      toggle_red_light(false, options)
      send_slack_message(options, message)

      puts message
    else
      message = "ALERT: #{failed_jobs_or_pipelines} failing jobs or pipelines! Switching to alarm state. :-("

      toggle_green_light(false, options)
      toggle_red_light(true, options)
      send_slack_message(options, message)

      puts message
    end
  end

  def failed_jobs_or_pipelines
    failed_jobs
  end
end
