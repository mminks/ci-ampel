module Jenkins
  def get_jenkins_json_jobs
    JSON.parse(get_response.body)['jobs']
  end

  def failed_jobs
    red_jobs = []

    get_jenkins_json_jobs.each do |job|
      next unless job['lastCompletedBuild']

      red_jobs << job['name'] if job['lastCompletedBuild']['result'] == 'FAILURE'
    end

    return red_jobs
  end
end
