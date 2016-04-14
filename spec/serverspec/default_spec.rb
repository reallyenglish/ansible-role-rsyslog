require 'spec_helper'
require 'serverspec'

rsyslog_package_name = 'rsyslog'
rsyslog_service_name = 'rsyslog'
rsyslog_config       = '/etc/rsyslog/rsyslog.conf'
rsyslog_user_name    = 'rsyslog'
rsyslog_user_group   = 'rsyslog'
rsyslog_work_dir     = '/var/spool/rsyslog'

os_default_syslog_service_name = 'syslogd'

case os[:family]
when 'freebsd'
  rsyslog_package_name = 'rsyslog8'
  rsyslog_service_name = 'rsyslogd'
  rsyslog_config_path  = '/usr/local/etc/rsyslog.conf'
  rsyslog_config_dir   = '/usr/local/etc/rsyslog.d'
  rsyslog_user_name    = 'root'
  rsyslog_user_group   = 'wheel'
  os_default_syslog_service_name = 'syslogd'
end

describe package(rsyslog_package_name) do
  it { should be_installed }
end 

describe service(rsyslog_service_name) do
  it { should be_running }
  it { should be_enabled }
end

# XXX due to bug in serverspec, these tests do not work
if os_default_syslog_service_name && 0 == 1
  describe service(os_default_syslog_service_name) do
    it { should_not be_running }
    it { should_not be_enabled }
  end
end

describe port(514) do
  it { should_not be_listening }
end

describe file(rsyslog_config_path) do
  it { should be_file }
  its(:content) { should match Regexp.escape("$FileOwner #{rsyslog_user_name}") }
  its(:content) { should match Regexp.escape("$FileGroup #{rsyslog_user_group}") }
  its(:content) { should match Regexp.escape("$WorkDirectory #{rsyslog_work_dir}") }
  its(:content) { should match Regexp.escape("$IncludeConfig #{rsyslog_config_dir}/*.cfg") }
end

describe file("#{rsyslog_config_dir}/200_client.cfg") do
  regex_to_test = [
    '$ActionQueueType LinkedList',
    '$ActionQueueFileName localhost:5140-queue',
    '$ActionResumeRetryCount -1',
    '$ActionQueueSaveOnShutdown on',
    '*.* @@localhost:5140;RSYSLOG_ForwardFormat'
  ]
  it { should be_file }
  regex_to_test.each do |r|
    its(:content) { should match Regexp.escape(r) }
  end
end
