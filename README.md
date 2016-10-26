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

| Variable | Description | Default |
|----------|-------------|---------|
| rsyslog\_service\_name | service name of rsyslog | {{ \_\_rsyslog\_service\_name }} |
| rsyslog\_package\_name | package name of rsyslog | {{ \_\_rsyslog\_package\_name }} |
| rsyslog\_conf\_dir | path to rsyslog.d directory | {{ \_\_rsyslog\_conf\_dir }} |
| rsyslog\_conf\_file | path to rsyslog.conf | {{ \_\_rsyslog\_conf\_file }} |
| rsyslog\_bin | path to rssylogd binary | {{ \_\_rsyslog\_bin }} |
| rsyslog\_mode | array of mode to run as. `local` acts as local syslog, logs to local files. `client` acts as a syslog client, forwards logs to remote host. `server` act as a syslog server, receives logs from remote. | ["local"] |
| rsyslog\_remote\_servers | array of remote syslog servers in the form of [ remote.example.com:514 ] | [] |
| rsyslog\_default\_syslog\_service\_name | service name of existing syslog service, which will be stopped and disabled | {{ \_\_rsyslog\_default\_syslog\_service\_name }} |
| rsyslog\_default\_log\_files | TBW | {{ \_\_rsyslog\_default\_log\_files }} |
| rsyslog\_config\_WorkDirectory | WorkDirectory | /var/spool/rsyslog |
| rsyslog\_config\_FileOwner | FileOwner | {{ \_\_rsyslog\_config\_FileOwner }} |
| rsyslog\_config\_FileGroup | FileGroup | {{ \_\_rsyslog\_config\_FileGroup }} |
| rsyslog\_imfile\_inputs | a dict of imfile inputs. see below | {} |
| rsyslog\_server\_config\_AllowedSender | when rsyslog\_mode is 'server', a list of allowed clients | [] |
| rsyslog\_server\_config\_listen\_port | when rsyslog\_mode is 'server', a list of ports that `rsyslogd` will listen on | {{ \_\_rsyslog\_server\_config\_listen\_port }} |

## rsyslog\_imfile\_inputs

rsyslog\_imfile\_inputs is a hash of files to read.

```yaml
rsyslog_imfile_inputs:
  dummy.log:
    path: /tmp/dummy.log
    tag: dummy
    facility: local1
```

this creates a config flagment like:

```
input(
  type="imfile"
  File="/tmp/dummy.log"
  Tag="dummy"
  Facility="local1"
)
```

## Debian

| Variable | Default |
|----------|---------|
| \_\_rsyslog\_service\_name | rsyslog |
| \_\_rsyslog\_package\_name | rsyslog |
| \_\_rsyslog\_conf\_file | /etc/rsyslog.conf |
| \_\_rsyslog\_conf\_dir | /etc/rsyslog.d |
| \_\_rsyslog\_bin | /usr/sbin/rsyslogd |
| \_\_rsyslog\_default\_syslog\_service\_name | "" |
| \_\_rsyslog\_default\_log\_files | ["/var/log/auth.log", "/var/log/cron", "/var/log/debug", "/var/log/maillog", "/var/log/messages", "/var/log/security"] |
| \_\_rsyslog\_config\_FileOwner | root |
| \_\_rsyslog\_config\_FileGroup | root |
| \_\_rsyslog\_server\_config\_listen\_port | [514] |

## FreeBSD

| Variable | Default |
|----------|---------|
| \_\_rsyslog\_service\_name | rsyslogd |
| \_\_rsyslog\_package\_name | rsyslog |
| \_\_rsyslog\_conf\_file | /usr/local/etc/rsyslog.conf |
| \_\_rsyslog\_conf\_dir | /usr/local/etc/rsyslog.d |
| \_\_rsyslog\_bin | /usr/local/sbin/rsyslogd |
| \_\_rsyslog\_default\_syslog\_service\_name | syslogd |
| \_\_rsyslog\_default\_log\_files | ["/var/log/auth.log", "/var/log/cron", "/var/log/debug", "/var/log/maillog", "/var/log/messages", "/var/log/security"] |
| \_\_rsyslog\_config\_FileOwner | root |
| \_\_rsyslog\_config\_FileGroup | wheel |
| \_\_rsyslog\_server\_config\_listen\_port | [514] |

## OpenBSD

| Variable | Default |
|----------|---------|
| \_\_rsyslog\_service\_name | rsyslogd |
| \_\_rsyslog\_package\_name | rsyslog |
| \_\_rsyslog\_conf\_file | /etc/rsyslog.conf |
| \_\_rsyslog\_conf\_dir | /etc/rsyslog.d |
| \_\_rsyslog\_bin | /usr/local/sbin/rsyslogd |
| \_\_rsyslog\_default\_syslog\_service\_name | "" |
| \_\_rsyslog\_default\_log\_files | ["/var/log/auth.log", "/var/log/cron", "/var/log/debug", "/var/log/maillog", "/var/log/messages", "/var/log/security"] |
| \_\_rsyslog\_config\_FileOwner | root |
| \_\_rsyslog\_config\_FileGroup | wheel |
| \_\_rsyslog\_server\_config\_listen\_port | [5140] |

## RedHat

| Variable | Default |
|----------|---------|
| \_\_rsyslog\_service\_name | rsyslog |
| \_\_rsyslog\_package\_name | rsyslog |
| \_\_rsyslog\_conf\_file | /etc/rsyslog.conf |
| \_\_rsyslog\_conf\_dir | /etc/rsyslog.d |
| \_\_rsyslog\_bin | /usr/sbin/rsyslogd |
| \_\_rsyslog\_default\_syslog\_service\_name | "" |
| \_\_rsyslog\_default\_log\_files | ["/var/log/auth.log", "/var/log/cron", "/var/log/debug", "/var/log/maillog", "/var/log/messages", "/var/log/security"] |
| \_\_rsyslog\_config\_FileOwner | root |
| \_\_rsyslog\_config\_FileGroup | root |
| \_\_rsyslog\_server\_config\_listen\_port | [514] |

Created by [yaml2readme.rb](https://gist.github.com/trombik/b2df709657c08d845b1d3b3916e592d3)

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  pre_tasks:
    - file: path=/tmp/dummy.log state=touch
      changed_when: false
  roles:
    - ansible-role-rsyslog
  vars:
    rsyslog_mode: "{% if ansible_os_family == 'OpenBSD' %}[ 'local', 'server', 'client' ]{% else %}[ 'local', 'client' ]{% endif %}"
    rsyslog_remote_servers:
      - 10.0.2.115:514
    rsyslog_imfile_inputs: "{% if ansible_os_family == 'OpenBSD' %}{}{% else %}{ 'dummy.log': { 'path': '/tmp/dummy.log', 'tag': 'dummy', 'facility': 'local1' } }{% endif %}"
    rsyslog_server_config_AllowedSender: "{% if ansible_os_family == 'OpenBSD' %}[ 'UDP, 127.0.0.1' ]{% else %}[]{% endif %}"

    - hosts: servers
      roles:
         - ansible-role-rsyslog
      vars:
        rsyslog_mode:
          - local
          - client
        rsyslog_remote_servers:
          - remote.example.com:514
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [ansible-role-init](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
