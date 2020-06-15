module Jenkins
  def get_jenkins_jobs_uri
    ENV['JENKINS_JOBS_URI'] ? URI("#{ENV['JENKINS_JOBS_URI']}/api/json?tree=jobs[name,lastCompletedBuild[number,result]]") : ''
  end

  def get_jenkins_user
    ENV['JENKINS_USER'] ? ENV['JENKINS_USER'] : ''
  end

  def get_jenkins_pass
    ENV['JENKINS_PASS'] ? ENV['JENKINS_PASS'] : ''
  end

  def get_jenkins_response
    begin
      Net::HTTP.start(
          get_jenkins_jobs_uri.host,
          get_jenkins_jobs_uri.port,
          :use_ssl => get_jenkins_jobs_uri.scheme == 'https',
          :verify_mode => OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        request = Net::HTTP::Get.new get_jenkins_jobs_uri.request_uri
        request.basic_auth get_jenkins_user, get_jenkins_pass

        return http.request(request).code
      end
    rescue => error
      return 503
    end
  end

  def is_healthy?
    return true if get_jenkins_response.to_i == 200
  end

  def get_jenkins_json_jobs
    JSON.parse(get_jenkins_response.body)['jobs']
  end

  def failed_jobs
    red_jobs = []

    get_jenkins_json_jobs.each do |job|
      next unless job['lastCompletedBuild']

      red_jobs << job['name'] if job['lastCompletedBuild']['result'] == 'FAILURE'
    end

    return red_jobs.size
  end
end
