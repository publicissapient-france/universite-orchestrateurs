podTemplate(label: 'mavenPod', inheritFrom: 'mypod',
        containers: [
                containerTemplate(name: 'maven', image: 'maven:3.3.9-jdk-8-alpine', ttyEnabled: true, command: 'cat'),
                containerTemplate(name: 'ssh', image: 'xebiafrance/ssh:alpine', ttyEnabled: true, command: 'cat'),
                containerTemplate(name: 'docker', image: 'docker:stable', ttyEnabled: true, command: 'cat'),
        ],
        volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')]
) {

    node('mavenPod') {

        git url: 'https://github.com/xebia-france/universite-orchestrateurs.git', credentialsId: 'tauffredou2'

        def version
        sh "git rev-parse --short HEAD > GIT_COMMIT"
        version = readFile('GIT_COMMIT').take(6)

        stage('Build') {
            container('maven') {
                sh 'cd applications/click-count && mvn -q -B clean package'
            }
        }

        stage('Results') {
            container('maven') {
                archive 'cd applications/click-count && target/clickCount.war'
            }
        }

        stage('Build image') {
            container('docker') {
                sh "docker build -t registry-service.ci.svc.cluster.local:5000/xebiafrance/click-count:${version} applications/click-count"
            }
        }

        stage('Push image') {
            container('docker') {
                sh "docker push registry-service.ci.svc.cluster.local:5000/xebiafrance/click-count:${version}"
            }
        }

        stage('Deploy on Staging') {
            dir('applications/click-count') {
                sh "sed -i 's#{{.VERSION}}#${version}#' marathon.json"
                sh "curl -X PUT -H 'Content-type: application/json' http://mesos-master1.private:8080/v2/groups -d@marathon.json"
            }
        }

    }
}