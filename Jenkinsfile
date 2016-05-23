node ('virtualbox') {
  stage 'Checkout'
  sh 'if [ ! -d ansible-role-hadoop-namenode ]; then mkdir ansible-role-hadoop-namenode; fi'
  dir('ansible-role-hadoop-namenode') {
    checkout scm
  }
  dir('ansible-role-hadoop-namenode') {
    stage 'bundle'
    sh 'bundle install --path vendor/bundle'
    sh 'if vagrant box list | grep trombik/ansible-freebsd-10.3-amd64 >/dev/null; then echo "installed"; else vagrant box add trombik/ansible-freebsd-10.3-amd64; fi'

    stage 'bundle exec kitchen test'
    sh 'bundle exec kitchen test'

    stage 'Notify'
    step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
  }
}
