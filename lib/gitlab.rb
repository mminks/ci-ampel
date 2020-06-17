module Gitlab
  def setup_gitlab_connection
    Gitlab.configure do |config|
      config.endpoint = "#{get_uri.scheme}://#{get_uri.host}/api/v4"
      config.private_token = get_credentials
    end
  end

  def get_all_gitlab_projects
    setup_gitlab_connection

    projects = []

    begin
      Gitlab.projects.auto_paginate do |project|
        projects << {
            :id => project.id,
            :name => project.name,
            :namespace => project.namespace.path,
            :path_with_namespace => project.path_with_namespace
        } if project.namespace.kind == "group" and ! project.archived
      end

      return projects
    rescue => error
      puts "#{error}"
    end
  end

  def failed_pipelines
    red_pipelines = []

    get_all_gitlab_projects.each do |project|
      id = project[:id]
      name = project[:name]
      namespace = project[:namespace]
      path_with_namespace = project[:path_with_namespace]

      begin
        if Gitlab.pipelines(id).first
          status = Gitlab.pipelines(id).first.status

          red_pipelines << "#{path_with_namespace}: #{status}" if status == "failed"
        end
      rescue => error
      end
    end

    red_pipelines.each do |item|
      puts item
    end if ENV['DEBUG']

    return red_pipelines
  end
end
