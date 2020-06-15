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

  JENKINS_JOBS_URI = URI("#{ENV['JENKINS_JOBS_URI']}/api/json?tree=jobs[name,lastCompletedBuild[number,result]]")
  JENKINS_USER = ENV['JENKINS_USER']
  JENKINS_PASS = ENV['JENKINS_PASS']

  def run(options)
    # get_all_gitlab_projects
    #
    # exit 0

    if !is_jenkins_healthy?
      message = "ALERT: Jenkins is not responding! Red light is on. :-("

      toggle_green_light(false, options)
      toggle_red_light(true, options)
      send_slack_message(options, message)

      puts message
    elsif evaluate_jenkins_job_colors.size == 0
      message = "OK: Everything is fine again! Green light is on. :-)"

      toggle_green_light(true, options)
      toggle_red_light(false, options)
      send_slack_message(options, message)

      puts message
    else
      message = "ALERT: #{evaluate_jenkins_job_colors.size} failing jenkins #{cpluralize(evaluate_jenkins_job_colors.size, 'job')}! Red light is on. :-("

      toggle_green_light(false, options)
      toggle_red_light(true, options)
      send_slack_message(options, message)

      puts message
    end
  end
end
