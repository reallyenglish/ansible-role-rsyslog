# ansible-role-rsyslog

Install rsyslog.

## Note for OpenBSD

Applications in base does not use `/dev/log`. This is because, instead of
`syslog(3)`, they use `sendsyslog(2)`, which was introduced in 5.6. The role
does not yet support this change, which means if you use the role, `rsyslog`
logs only from third-party applications. You will lost everything else.

The `rsyslog` package in the ports tree does not enable `imfile` module. You
cannot use it.

Port 514 cannot used with `rsyslog_mode` == `local`.

# Requirements

None

# Role Variables


| variable | description | default |
|----------|-------------|---------|
| rsyslog\_service\_name  | service name of rsyslog | see var file |
| rsyslog\_package\_name  | package name of rsyslog | see var file |
| rsyslog\_conf\_dir      | path to rsyslog.d directory | see var file |
| rsyslog\_conf\_file     | path to rsyslog.conf | see var file |
| rsyslog\_bin           | path to rssylogd binary | see var file |
| rsyslog\_mode          | an array of mode to run as. `local` acts as local syslog, logs to local files. `client` acts as a syslog client, forwards logs to remote host. `server` act as a syslog server, receives logs from remote. | local |
| rsyslog\_remote\_servers | an array of remote syslog servers in the form of [ remote.example.com:514 ] | [] |
| rsyslog\_default\_syslog\_service\_name | service name of existing syslog service, which will be stopped | see var file |
| rsyslog\_default\_log\_files | TBW | TBW |
| rsyslog\_config\_WorkDirectory | WorkDirectory | /var/spool/rsyslog |
| rsyslog\_config\_FileOwner | FileOwner | see var file |
| rsyslog\_config\_FileGroup | FileGroup | see var file |
| rsyslog\_imfile\_inputs    | a dict of imfile inputs. see below | {} |

# Dependencies

None

# Example Playbook

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

## rsyslog\_imfile\_inputs

rsyslog\_imfile\_inputs is a hash of files to read.

    rsyslog_imfile_inputs:
      dummy.log:
        path: /tmp/dummy.log
        tag: dummy
        facility: local1

this creates a config flagment like:

    input(
      type="imfile"
      File="/tmp/dummy.log"
      Tag="dummy"
      Facility="local1"
    )

# License

BSD

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
