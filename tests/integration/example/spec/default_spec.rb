require 'spec_helper'

class ServiceNotReady < StandardError
end

sleep 10 if ENV['JENKINS_HOME']

context 'after provisioning finished' do

  now = Time.new
  message = "%s %s" % [now.to_s, Digest::SHA256.hexdigest(now.to_i.to_s) ]
  default_log_file = '/var/log/messages'

  describe server(:client1) do

    it 'should be able to ping server' do
      result = current_server.ssh_exec("ping -c 1 #{ Shellwords.escape(server(:server1).server.address) } && echo OK")
      expect(result).to match(/OK/)
    end

    it 'should be able to log locally with logger' do
      result = current_server.ssh_exec("logger #{ Shellwords.escape(message) } && echo OK")
      expect(result).to match(/OK/)
    end

    it 'should find the message in local log file' do
      sleep ENV['JENKINS_HOME'] ? 3 : 1
      result = current_server.ssh_exec("grep #{ Shellwords.escape(message) } #{ Shellwords.escape(default_log_file) } && echo OK")
      expect(result).to match(/OK/)
    end

  end

  describe server(:server1) do

    it 'should be able to ping client' do
      result = current_server.ssh_exec("ping -c 1 #{ server(:client1).server.address } && echo OK")
      expect(result).to match(/OK/)
    end

    it 'should find the message from client in local log file' do
      # rsyslog starts listening but, somehow, the log does not show up in the
      # file.
      sleep ENV['JENKINS_HOME'] ? 40 : 20
      result = current_server.ssh_exec("grep #{ Shellwords.escape(message) } #{ Shellwords.escape(default_log_file) } && echo OK")
      expect(result).to match(/OK/)
    end

  end

end
