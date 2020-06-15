module Gitlab
  def setup_gitlab_connection
    Gitlab.configure do |config|
      config.endpoint = ENV['GITLAB_API_ENDPOINT'] ? ENV['GITLAB_API_ENDPOINT'] : ''
      config.private_token = ENV['GITLAB_TOKEN'] ? ENV['GITLAB_TOKEN'] : ''
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
        } if project.namespace.kind == "group"
      end
    rescue => error
      puts "#{error}"
    end

    projects.each do |project|
      id = project[:id]
      name = project[:name]
      namespace = project[:namespace]
      path_with_namespace = project[:path_with_namespace]

      if Gitlab.pipelines(id).first
        status = Gitlab.pipelines(id).first.status

        if status == "failed"
          puts "#{path_with_namespace}: #{status}"
        end
      end
    end
  end
end
