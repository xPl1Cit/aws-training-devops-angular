#!/bin/bash

# Retrieve AWS Account ID dynamically
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Set the AWS region (default to us-east-1 if not provided)
REGION=${1:-us-east-1}

# Set the image version (default to v1)
VERSION=${2:-v1}

# Set the environment (e.g., test or prod), default to "test"
ENVIRONMENT=${3:-test}

# Set the full ECR repository name with environment suffix
REPOSITORY_NAME="capstone-al-angular-${ENVIRONMENT}"

echo "📦 Targeting repository: $REPOSITORY_NAME in $REGION (env: $ENVIRONMENT)"

# Check if the repository exists
REPO_EXISTS=$(aws ecr describe-repositories \
  --repository-names "$REPOSITORY_NAME" \
  --region "$REGION" \
  --query 'repositories[0].repositoryName' \
  --output text 2>/dev/null)

if [ "$REPO_EXISTS" == "$REPOSITORY_NAME" ]; then
    echo "✅ Repository $REPOSITORY_NAME already exists in ECR."
else
    echo "➕ Repository $REPOSITORY_NAME does not exist. Creating it now..."
    aws ecr create-repository --repository-name "$REPOSITORY_NAME" --region "$REGION"
    echo "✅ Repository $REPOSITORY_NAME created successfully."
fi

# Log in to Amazon ECR
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# Build and tag the Docker image
docker build -t "$REPOSITORY_NAME" .

docker tag "$REPOSITORY_NAME:latest" "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest"
docker tag "$REPOSITORY_NAME:latest" "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$VERSION"

# Push to ECR
docker push "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest"
docker push "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$VERSION"
