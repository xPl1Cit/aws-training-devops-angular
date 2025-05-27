pipeline {
    agent {
        docker {
            image 'amazonlinux:2'
            args '-u root'
        }
    }

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS Region for ECR')
    }

    environment {
        VERSION = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Install AWS CLI') {
            steps {
                sh '''
                    yum install -y unzip curl
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip awscliv2.zip
                    ./aws/install
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Determine Environment') {
            steps {
                script {
                    def branch = env.BRANCH_NAME
                    env.ENVIRONMENT = (branch == 'prod') ? 'prod' : 'test'
                    echo "🌱 Branch: ${branch}, deploying to: ${env.ENVIRONMENT}"
                }
            }
        }

        stage('Deploy to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials', // <-- Make sure this exists in Jenkins
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region ${AWS_REGION}
                        aws sts get-caller-identity

                        chmod +x ./deploy-to-ecr.sh
                        ./deploy-to-ecr.sh ${AWS_REGION} ${VERSION} ${ENVIRONMENT}
                    '''
                }
            }
        }
    }
}
