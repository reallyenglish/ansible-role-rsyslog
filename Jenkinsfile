node ('virtualbox') {
  stage 'Checkout'
  sh 'if [ ! -d ansible-role-rsyslog ]; then mkdir ansible-role-rsyslog; fi'
  dir('ansible-role-rsyslog') {
    checkout scm
  }
  dir('ansible-role-rsyslog') {
    stage 'bundle'
    sh 'bundle install --path vendor/bundle'
    sh 'if vagrant box list | grep trombik/ansible-freebsd-10.3-amd64 >/dev/null; then echo "installed"; else vagrant box add trombik/ansible-freebsd-10.3-amd64; fi'

    stage 'bundle exec kitchen test'
    sh 'bundle exec kitchen test'

    stage 'Notify'
    step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
  }
}
