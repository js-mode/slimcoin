# Referenced from https://github.com/airstand/litecoin/blob/master/Jenkinsfile

def slimcoin_repo = 'https://github.com/js-mode/slimcoin.git'
def repo_version = '005'
properties([
  parameters([
    string(name: 'slimcoin_repo_branch', description: 'Branch to build and deploy slimcoin from', defaultValue: 'master'),
    string(name: 'image_repo_tag', description: 'Full Docker image name with repository included.', defaultValue: 'docker.io/slimcoin/slimcoin'),
    string(name: 'kubeconfig', description: 'The name of the kubeconfig file in your Jenkins .kube directory', defaultValue: 'slimcoin')
  ])
])

throttle([]) {
  node() {
    timestamps {
      try {

        git url: slimcoin_repo, branch: params.slimcoin_repo_branch

        stage('Build') {
          sh """
            docker build -t ${params.image_repo_tag}:${repo_version} .
            docker push ${params.image_repo_tag}:${repo_version}
          """
        }

        stage('Deploy') {
          sh """
            kubectl --kubeconfig ~/.kube/${params.kubeconfig} apply -f slimcoin.yaml
          """
        }
      } catch (ex) {
        currentBuild.result = 'FAILURE'

        sh """
          echo FAILURE
        """
      }

    }
  }
}
