pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '436515648470'
        AWS_REGION = 'eu-east-1' // Default region, change if needed or inject dynamically
        IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
        REPO_NAME = ''
        ECR_URI = ''
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Debug Branch') {
            steps {
                echo "Current branch: ${env.BRANCH_NAME}"
                echo "Using AWS Region: ${env.AWS_REGION}"
            }
        }

        stage('Set Target ECR') {
            when {
                anyOf {
                    branch 'test'
                    branch 'prod'
                }
            }
            steps {
                script {
                    if (env.BRANCH_NAME == 'test') {
                        env.REPO_NAME = 'angular-test'
                    } else if (env.BRANCH_NAME == 'prod') {
                        env.REPO_NAME = 'angular-prod'
                    }
                    env.ECR_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.REPO_NAME}"
                    echo "📦 Target ECR: ${env.ECR_URI}"
                }
            }
        }

        stage('Create ECR Repository if Missing') {
            when {
                expression { return env.REPO_NAME != '' }
            }
            steps {
                script {
                    sh """
                        if ! aws ecr describe-repositories --repository-names ${env.REPO_NAME} --region ${env.AWS_REGION} 2>/dev/null; then
                            echo "🔧 ECR repository ${env.REPO_NAME} does not exist. Creating..."
                            aws ecr create-repository --repository-name ${env.REPO_NAME} --region ${env.AWS_REGION}
                        else
                            echo "✅ ECR repository ${env.REPO_NAME} already exists."
                        fi
                    """
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { return env.REPO_NAME != '' }
            }
            steps {
                sh "docker build -t ${env.REPO_NAME}:${env.IMAGE_TAG} ."
            }
        }

        stage('Login to ECR') {
            when {
                expression { return env.REPO_NAME != '' }
            }
            steps {
                sh """
                    aws ecr get-login-password --region ${env.AWS_REGION} | \
                    docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Tag & Push to ECR') {
            when {
                expression { return env.REPO_NAME != '' }
            }
            steps {
                sh """
                    docker tag ${env.REPO_NAME}:${env.IMAGE_TAG} ${env.ECR_URI}:${env.BRANCH_NAME}
                    docker push ${env.ECR_URI}:${env.BRANCH_NAME}
                """
            }
        }
    }
}
