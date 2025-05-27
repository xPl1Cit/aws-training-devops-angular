#!/bin/bash

# Retrieve AWS Account ID dynamically
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Set the AWS region (You can pass this as an argument or use a default)
REGION=${1:-us-east-1}  # Default to us-east-1 if no region is provided

# Set the repository name
REPOSITORY_NAME="capstone-al-angular"

# Check if the repository exists
REPO_EXISTS=$(aws ecr describe-repositories --repository-names $REPOSITORY_NAME --region $REGION --query 'repositories[0].repositoryName' --output text)

if [ "$REPO_EXISTS" == "$REPOSITORY_NAME" ]; then
    echo "Repository $REPOSITORY_NAME already exists in ECR."
else
    echo "Repository $REPOSITORY_NAME does not exist. Creating it now..."
    aws ecr create-repository --repository-name $REPOSITORY_NAME --region $REGION
    echo "Repository $REPOSITORY_NAME created successfully."
fi

# Log in to Amazon ECR
docker login -u AWS -p $(aws ecr get-login-password --region $REGION) $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME

VERSION=${2:-v1}  # Default to 'v1' if no version is provided

docker build -t $REPOSITORY_NAME .

docker tag $REPOSITORY_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest
docker tag $REPOSITORY_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$VERSION

# Push the Docker image to ECR (both latest and version tags)
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$VERSION
