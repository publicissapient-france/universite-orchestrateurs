podTemplate(label: 'mavenPod', inheritFrom: 'mypod',
        containers: [
                containerTemplate(name: 'maven', image: 'maven:3.3.9-jdk-8-alpine', ttyEnabled: true, command: 'cat'),
        ],
        volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')]
) {

    node('mavenPod') {

        git url: 'https://github.com/xebia-france/universite-orchestrateurs.git', credentialsId: 'tauffredou2'

        def version
        sh "git rev-parse --short HEAD > GIT_COMMIT"
        version = readFile('GIT_COMMIT').take(6)
        String imageTag = "10.233.57.46:5000/xebiafrance/uo-click-count:${version}"

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
            sh "docker build -t ${imageTag} applications/click-count"
        }

        stage('Push image') {
            sh "docker push ${imageTag}"
        }

        stage('Deploy on Staging') {
            dir('applications/click-count') {
                sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
                sh "sed -i.bak 's#__FRONTEND_IMAGE__#${imageTag}#' ./k8s/dev/*.yml"
                sh "kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/"
                echo 'To access your environment run `kubectl proxy`'
                echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/clickcount-service:8080/"
            }
        }

    }
}