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
            dir('applications/click-count') {
                archive 'target/clickCount.war'
            }
        }

        stage('Build image') {
            sh "docker build -t 10.233.57.46:5000/xebiafrance/click-count:${version} applications/click-count"
        }

        stage('Push image') {
            sh "docker push 10.233.57.46:5000/xebiafrance/click-count:${version}"
        }

        stage('Deploy on Staging') {
            dir('applications/click-count') {
                sh "sed -i 's#{{.VERSION}}#${version}#' k8s.json"
                sh "kubectl apply -f k8s.json"
            }
        }

    }
}