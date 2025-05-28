pipeline {
    agent {
        docker {
            image 'amazonlinux:2'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'us-east-1', description: 'AWS Region for ECR')
    }

    environment {
        VERSION = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Install Prerequisites') {
            steps {
                sh '''
                    # Update and install necessary packages
                    yum update -y
                    yum install -y unzip curl tar gzip docker

                    # Download and install AWS CLI v2
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    ./aws/install

                    # Install Docker CLI
                    curl -LO https://download.docker.com/linux/static/stable/x86_64/docker-24.0.5.tgz
                    tar -xzf docker-24.0.5.tgz --strip 1 -C /usr/local/bin docker/docker
                    rm -rf docker-24.0.5.tgz

                    # Verify installations
                    aws --version
                    docker --version
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

        stage('Build Docker and deploy to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
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
		
        stage('Trigger Deployment') {
            steps {
                script {
                    build job: 'Deploy Angular',
                          parameters: [
                              string(name: 'REGION', value: ${AWS_REGION}),
                              string(name: 'VERSION', value: ${VERSION}),
							  string(name: 'ENVIRONMENT', value: ${ENVIRONMENT})
                          ],
                          wait: false
                }
            }
        }
    }
}
