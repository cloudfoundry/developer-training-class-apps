# frozen_string_literal: true

require 'rufus-scheduler'

# Scheduler for recording statuses
class AppScheduler
  def initialize(status_manager)
    @scheduler = Rufus::Scheduler.new
    @status_manager = status_manager
  end

  def run
    @job = scheduler.schedule_every '10s' do
      puts 'recording status'
      uuid = status_manager.record_random_status
      puts uuid
    end
    scheduler
  end

  def kill
    job.kill if job.running?
  end

  private

  attr_reader :scheduler, :status_manager, :job
end

def vcap_services
  ENV.fetch('VCAP_SERVICES', nil)
end

def rest_backend_url
  return nil if vcap_services.to_s.empty?
  json = JSON.parse(vcap_services)
  service_array = json['user-provided']
  return nil if service_array.nil?
  service_array.select do |service|
    service['name'].start_with?('rest-backend')
  end.first['credentials']['url']
end
