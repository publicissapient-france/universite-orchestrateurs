#! /bin/bash
set -e

exec /usr/local/bin/jenkins-slave.sh -master http://jenkins:8080 \
                                     -username admin \
                                     -password $(cat /run/secrets/jenkins_admin_password) \
                                     -executors 1
