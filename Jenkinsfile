pipeline {
     agent {
        docker { image 'elixir:latest' }
    }
    stages {
        stage('Build') {
            steps {
                sh 'echo "Building..."'
                sh 'mix local.hex --force'
                sh 'mix local.rebar --force'
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