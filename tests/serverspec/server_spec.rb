require "spec_helper"

rsyslog_package_name = "rsyslog"
rsyslog_service_name = "rsyslog"
rsyslog_user_name    = "root"
rsyslog_user_group   = "root"
rsyslog_work_dir     = "/var/spool/rsyslog"
rsyslog_config_dir   = "/etc/rsyslog.d"
rsyslog_config_path  = "/etc/rsyslog.conf"
rsyslog_ports        = [514]

os_default_syslog_service_name = nil

case os[:family]
when "freebsd"
  rsyslog_service_name = "rsyslogd"
  rsyslog_config_path  = "/usr/local/etc/rsyslog.conf"
  rsyslog_config_dir   = "/usr/local/etc/rsyslog.d"
  rsyslog_user_name    = "root"
  rsyslog_user_group   = "wheel"
  os_default_syslog_service_name = "syslogd"
when "openbsd"
  rsyslog_service_name = "rsyslogd"
  rsyslog_user_group   = "wheel"
  rsyslog_ports        = [5140]
end

rsyslog_server_config_path = "#{rsyslog_config_dir}/400_server.cfg"

describe package(rsyslog_package_name) do
  it { should be_installed }
end

describe service(rsyslog_service_name) do
  it { should be_running }
  it { should be_enabled }
end

if os_default_syslog_service_name
  describe service(os_default_syslog_service_name) do
    it do
      pending "due to bug in serverspec, these tests do not work"
      should_not be_running
    end
    it do
      pending "due to bug in serverspec, these tests do not work"
      should_not be_enabled
    end
  end
end

rsyslog_ports.each do |port|
  describe port(port) do
    it { should be_listening }
  end
end

describe file(rsyslog_config_path) do
  it { should be_file }
  its(:content) { should match Regexp.escape("$FileOwner #{rsyslog_user_name}") }
  its(:content) { should match Regexp.escape("$FileGroup #{rsyslog_user_group}") }
  its(:content) { should match Regexp.escape("$WorkDirectory #{rsyslog_work_dir}") }
  its(:content) { should match Regexp.escape("$IncludeConfig #{rsyslog_config_dir}/*.cfg") }
end

describe file(rsyslog_server_config_path) do
  it { should be_file }

  rsyslog_ports.each do |port|
    udp_re = [
      'module(load="imudp")',
      "input(",
      '    type="imudp"',
      "    port=\"#{port}\"",
      ")"
    ].map { |i| Regexp.escape(i) }.join('\n')
    its(:content) { should match(/#{ udp_re }/) } if os[:family] != "openbsd"
    tcp_re = [
      'module(load="imtcp")',
      "input(",
      '    type="imtcp"',
      "    port=\"#{port}\"",
      ")"
    ].map { |i| Regexp.escape(i) }.join('\n')
    its(:content) { should match(/#{ tcp_re }/) }
  end

  its(:content) { should match Regexp.escape("$AllowedSender UDP, 192.168.0.0/16") }
  its(:content) { should match Regexp.escape("$AllowedSender TCP, 192.168.0.0/16") }
end
