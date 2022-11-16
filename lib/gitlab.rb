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
    red_pipelines = {}

    get_all_gitlab_projects.each do |project|
      id = project[:id]
      path_with_namespace = project[:path_with_namespace]

      begin
        if @master
            Gitlab.pipelines(id).each do |pipeline|
              next if pipeline.ref != "master"

              break if pipeline.status.match(/success|manual/)

              if pipeline.status == "failed"
                red_pipelines[id] = path_with_namespace

                break
              end
            end
        else
          if Gitlab.pipelines(id).first
            if Gitlab.pipelines(id).first.status == "failed"
              red_pipelines[id] = path_with_namespace
            end
          end
        end
      rescue => error
      end
    end

    red_pipelines.each do |project_id, description|
      # show some debug output
      puts "name: #{description} (project id: #{project_id})" if ENV['DEBUG']

      # automatically rerun last failed job
      rerun_failed_job(project_id) if @rerun
    end

    return red_pipelines
  end

  def rerun_failed_job(project_id)
    job_id = Gitlab.jobs(project_id, { scope: ["failed"] }).first.to_h["id"]

    puts "failed job id is: #{job_id}" if ENV['DEBUG']

    # finally rerun failed job
    job_retry = Gitlab.job_retry(project_id, job_id)

    if job_retry && ENV['DEBUG']
      puts "job rerun successfully started with job id: #{job_retry.to_h['id']}"
    end
  end
end
