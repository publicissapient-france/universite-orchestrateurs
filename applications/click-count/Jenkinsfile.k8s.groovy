podTemplate(label: 'mavenPod', inheritFrom: 'mypod', containers: [
        containerTemplate(name: 'maven', image: 'maven:3.3.9-jdk-8-alpine', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'ssh', image: 'xebiafrance/ssh:alpine', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'docker', image: 'docker:stable', ttyEnabled: true, command: 'cat'),
]) {

    node('mavenPod') {

        def version
        git url: 'https://github.com/xebia-france/universite-orchestrateurs.git', credentialsId: 'tauffredou2'

        container('ssh') {
//            checkout scm
            stage('Preparation') {
                sh "git rev-parse --short HEAD > GIT_COMMIT"
                version = readFile('GIT_COMMIT').take(6)
            }
        }

        stage('Build') {
            container('maven') {
                sh 'cd applications/click-count && mvn clean package'
            }
        }

        stage('Results') {
            container('maven') {
                archive 'cd applications/click-count && target/clickCount.war'
            }
        }

        stage('Build image') {
            container('docker') {
                sh "docker build -t registry.mesos.uo.techx.fr/xebiafrance/click-count:${version} applications/click-count"
            }
        }

        stage('Push image') {
            container('docker') {
                sh "docker push registry.mesos.uo.techx.fr/xebiafrance/click-count:${version}"
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