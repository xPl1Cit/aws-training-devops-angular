pipeline {
    agent any

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS Region for ECR')
    }

    environment {
        VERSION = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Determine Environment') {
            steps {
                script {
                    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    env.BRANCH_NAME = branch
                    env.ENVIRONMENT = (branch == 'prod') ? 'prod' : 'test'
                    echo "🌱 Branch: ${env.BRANCH_NAME}, deploying to: ${env.ENVIRONMENT}"
                }
            }
        }

        stage('Deploy to ECR') {
            steps {
                sh """
                chmod +x ./deploy-to-ecr.sh
                ./deploy-to-ecr.sh ${params.AWS_REGION} ${VERSION} ${ENVIRONMENT}
                """
            }
        }
    }
}
