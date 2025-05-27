pipeline {
    agent any

	parameters {
        choice(
            name: 'AWS_REGION',
            choices: ['eu-central-1', 'us-east-1', 'us-west-2'],
            description: 'Select the AWS Region to deploy to.'
        )
    }

    environment {
        AWS_ACCOUNT_ID = '436515648470'
        IMAGE_TAG = "${BRANCH_NAME}-${BUILD_NUMBER}"
        REPO_NAME = ''
        ECR_URI = ''
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
                    env.ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
                    echo "📦 Target ECR: ${ECR_URI}"
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
                        if ! aws ecr describe-repositories --repository-names ${REPO_NAME} --region ${AWS_REGION} 2>/dev/null; then
                            echo "🔧 ECR repository ${REPO_NAME} does not exist. Creating..."
                            aws ecr create-repository --repository-name ${REPO_NAME} --region ${AWS_REGION}
                        else
                            echo "✅ ECR repository ${REPO_NAME} already exists."
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
                sh "docker build -t ${REPO_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Login to ECR') {
            when {
                expression { return env.REPO_NAME != '' }
            }
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Tag & Push to ECR') {
            when {
                expression { return env.REPO_NAME != '' }
            }
            steps {
                sh """
                    docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_URI}:${BRANCH_NAME}
                    docker push ${ECR_URI}:${BRANCH_NAME}
                """
            }
        }
    }
}
