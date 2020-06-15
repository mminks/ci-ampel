module Jenkins
  def get_jenkins_response
    begin
      Net::HTTP.start(
          JENKINS_JOBS_URI.host,
          JENKINS_JOBS_URI.port,
          :use_ssl => JENKINS_JOBS_URI.scheme == 'https',
          :verify_mode => OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        request = Net::HTTP::Get.new JENKINS_JOBS_URI.request_uri
        request.basic_auth JENKINS_USER, JENKINS_PASS

        return http.request(request).code
      end
    rescue => error
      return 503
    end
  end

  def is_jenkins_healthy?
    return true if get_jenkins_response.to_i == 200
  end

  def get_jenkins_json_jobs
    JSON.parse(get_jenkins_response.body)['jobs']
  end

  def evaluate_jenkins_job_colors
    red_jobs = []

    get_jenkins_json_jobs.each do |job|
      next unless job['lastCompletedBuild']

      red_jobs << job['name'] if job['lastCompletedBuild']['result'] == 'FAILURE'
    end

    return red_jobs
  end
end
