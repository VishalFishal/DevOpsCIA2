pipeline {
    agent any
    
    environment {
        // UPDATE THESE VARIABLES
        AWS_ACCOUNT_ID = '525710163506' // e.g., 123456789012
        AWS_REGION     = 'ap-south-1'           // e.g., us-east-1
        ECR_REPO_NAME  = 'my-node-app'         // The name of your ECR repo
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image..."
                    sh "docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} ."
                }
            }
        }
        
        stage('Login to ECR') {
            steps {
                script {
                    echo "Logging into ECR..."
                    // Uses the EC2 IAM Role permissions
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URL}"
                }
            }
        }
        
        stage('Tag & Push Image') {
            steps {
                script {
                    echo "Pushing image to ECR..."
                    // Tag the image with the ECR registry URL
                    sh "docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${REGISTRY_URL}/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    sh "docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${REGISTRY_URL}/${ECR_REPO_NAME}:latest"
                    
                    // Push specific version and latest
                    sh "docker push ${REGISTRY_URL}/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    sh "docker push ${REGISTRY_URL}/${ECR_REPO_NAME}:latest"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Deploying container to EC2..."
                    // 1. Stop existing container (ignore error if it doesn't exist)
                    sh "docker stop node-app || true"
                    
                    // 2. Remove existing container (ignore error if it doesn't exist)
                    sh "docker rm node-app || true"
                    
                    // 3. Run the new container mapping port 3000
                    sh "docker run -d -p 3000:3000 --name node-app ${REGISTRY_URL}/${ECR_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded! Image pushed to ECR.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}