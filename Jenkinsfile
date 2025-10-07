pipeline {
     agent {
        dockerfile {

         }
    }
    stages {
        stage('Build') {
            steps {
                sh 'echo "Checking environment..."'
                sh 'id'
                sh 'env | sort'
                sh 'ls -ld /'
                sh 'echo WORKSPACE=$WORKSPACE'
                sh 'echo HOME=$HOME'
                sh 'echo MIX_HOME=$MIX_HOME'
                sh 'pwd'
                sh 'echo "Building..."'
                sh 'mix deps.get'
                sh 'mix compile'
            }
        }
        stage('Test') {
            steps {
                sh 'echo "Testing..."'
                sh 'mix test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo "Deploying..."'
                sh 'echo TODO'
                // TODO
            }
        }
    }
}