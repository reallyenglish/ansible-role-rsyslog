ansible-role-rsyslog
====================

Install rsyslog

Requirements
------------

None

Role Variables
--------------


| variable | description | default |
|----------|-------------|---------|
| rsyslog_service_name  | service name of rsyslog | see var file |
| rsyslog_package_name  | package name of rsyslog | see var file |
| rsyslog_conf_dir      | path to rsyslog.d directory | see var file |
| rsyslog_conf_file     | path to rsyslog.conf | see var file |
| rsyslog_bin           | path to rssylogd binary | see var file |
| rsyslog_mode          | an array of mode to run as. `local` acts as local syslog, logs to local files. `client` acts as a syslog client, forwards logs to remote host. `server` act as a syslog server, receives logs from remote. | local |
| rsyslog_remote_servers | an array of remote syslog servers in the form of [ remote.example.com:514 ] | [] |
| rsyslog_default_syslog_service_name | service name of existing syslog service, which will be stopped | see var file |
| rsyslog_default_log_files | TBW | TBW |
| rsyslog_config_WorkDirectory | WorkDirectory | /var/spool/rsyslog |
| rsyslog_config_FileOwner | FileOwner | see var file |
| rsyslog_config_FileGroup | FileGroup | see var file |


Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - ansible-role-rsyslog
      vars:
        rsyslog_mode:
          - local
          - client
        rsyslog_remote_servers:
          - remote.example.com:514

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
