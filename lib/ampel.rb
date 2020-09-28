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

  def initialize(options)
    @jenkins = options[:jenkins] ? true : false
    @gitlab = options[:gitlab] ? true : false
    @dry_run = options[:dry_run] ? true : false
    @slack = options[:slack] ? true : false
  end

  def run
    if !is_healthy?
      message = "ALERT: Automation server is not responding! Switching to alarm state."

      toggle_green_light(false)
      toggle_red_light(true)
      send_slack_message(message)

      puts message

      exit 0
    end

    # save failed jobs or pipelines once in a variable
    failed = result

    if failed.size == 0
      message = "OK: Everything is fine again! Green light is on."

      toggle_green_light(true)
      toggle_red_light(false)
      ### do not send a message if everything is green
      # send_slack_message(message)

      puts message
    else
      message = "ALERT: #{failed.size} failing jobs or pipelines: #{failed.map { |item| item.gsub(/:.*/,'') }.join(", ")}. Switching to alarm state."

      toggle_green_light(false)
      toggle_red_light(true)
      send_slack_message(message)

      puts message
    end
  end

  def get_uri
    if @jenkins
      ENV['BASE_URI'] ? URI("#{ENV['BASE_URI']}/api/json?tree=jobs[name,lastCompletedBuild[number,result]]") : ''
    elsif @gitlab
      ENV['BASE_URI'] ? URI("#{ENV['BASE_URI']}/api/v4/projects") : ''
    end
  end

  def get_credentials
    if ENV['USER'] && ENV['PASS'] && ENV['TOKEN']
      puts "ERROR: Please specify 'USER' and 'PASSWORD' _OR_ 'TOKEN'."

      exit 1
    elsif ENV['USER'] && ENV['PASS'] && ! ENV['TOKEN']
      ENV['USER'] = ENV['USER']
      ENV['PASS'] = ENV['PASS']
    elsif ENV['TOKEN'] && ! (ENV['USER'] && ENV['PASS'])
      ENV['TOKEN'] = ENV['TOKEN']
    end
  end

  def result
    failed_jobs if @jenkins
    failed_pipelines if @gitlab
  end

  def set_auth_parameters(request)
    if @jenkins
      return request.basic_auth get_jenkins_user, get_jenkins_pass
    elsif @gitlab
      return request['Authorization'] = "Bearer #{get_credentials}"
    end
  end

  def get_response
    begin
      Net::HTTP.start(
          get_uri.host,
          get_uri.port,
          :use_ssl => get_uri.scheme == 'https',
          :verify_mode => OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        request = Net::HTTP::Get.new(get_uri.request_uri)
        set_auth_parameters(request)

        return http.request(request).code
      end
    rescue
      return 503
    end
  end

  def is_healthy?
    # 200 OK for jenkins
    # 404 NOT FOUND for gitlab
    return true if get_response.to_i == 200
  end
end
