require 'spec_helper'

rsyslog_package_name = 'rsyslog'
rsyslog_service_name = 'rsyslog'
rsyslog_user_name    = 'root'
rsyslog_user_group   = 'root'
rsyslog_work_dir     = '/var/spool/rsyslog'
rsyslog_config_dir   = '/etc/rsyslog.d'
rsyslog_config_path  = '/etc/rsyslog.conf'
rsyslog_default_log_file = '/var/log/messages'

os_default_syslog_service_name = nil

case os[:family]
when 'freebsd'
  rsyslog_service_name = 'rsyslogd'
  rsyslog_config_path  = '/usr/local/etc/rsyslog.conf'
  rsyslog_config_dir   = '/usr/local/etc/rsyslog.d'
  rsyslog_user_name    = 'root'
  rsyslog_user_group   = 'wheel'
  os_default_syslog_service_name = 'syslogd'
when 'openbsd'
  rsyslog_service_name = 'rsyslogd'
  rsyslog_user_name    = 'root'
  rsyslog_user_group   = 'wheel'
  os_default_syslog_service_name = 'syslogd'
when 'ubuntu'
  rsyslog_default_log_file = '/var/log/syslog'
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

case os[:family]
when 'openbsd'
  describe port(514) do
    it { should be_listening }
  end
else
  describe port(514) do
    it { should_not be_listening }
  end
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
    '$ActionQueueFileName 10.0.2.115:514-queue',
    '$ActionResumeRetryCount -1',
    '$ActionQueueSaveOnShutdown on',
    '*.* @@10.0.2.115:514;RSYSLOG_ForwardFormat'
  ]
  it { should be_file }
  regex_to_test.each do |r|
    its(:content) { should match Regexp.escape(r) }
  end
end

case os[:family]
when 'openbsd'
  # rsyslog package does not install imfile
else
  describe file('/tmp/dummy.log') do
    it { should be_file }
  end

  # input(
  #   type="imfile"
  #   File="/tmp/dummy.log"
  #   Tag="dummy"
  #   Facility="local1"
  # )

  describe file("#{ rsyslog_config_dir }/900_dummy.log.cfg") do
    it { should be_file }
    its(:content) { should match Regexp.escape('File="/tmp/dummy.log"') }
    its(:content) { should match(/Tag="dummy"/) }
    its(:content) { should match(/Facility="local1"/) }
  end
end

sig = Digest::SHA256.hexdigest(Time.new.to_i.to_s)
describe command("logger #{ Shellwords.escape(sig) }") do
  its(:stderr) { should eq '' }
  its(:stdout) { should eq '' }
  its(:exit_status) { should eq 0 }
end

describe command("grep #{ Shellwords.escape(sig) } #{ Shellwords.escape(rsyslog_default_log_file) }") do
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/#{ Regexp.escape(sig) }/) }
  its(:exit_status) { should eq 0 }
end
