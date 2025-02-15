pipeline {
    agent any
    environment {
        TF_VERSION = '1.0.11'  // specify your Terraform version
        AWS_REGION = "ap-south-1"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')  // Store AWS credentials in Jenkins credentials manager
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }
    stages {
        stage('IAM user aws configuring') {
            steps {
                script {
                     sh """
                    echo "Configuring AWS CLI..."
                    aws configure set region $AWS_REGION
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    """
                }
            }
        }
        stage('Initialize Terraform') {
            steps {
                script {
                    // Initialize Terraform (e.g., modules and providers)
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    // Run terraform plan to validate the configuration
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                input 'Approve the Apply?'  // Manual approval step before applying changes
                script {
                    // Apply the terraform configuration
                    sh 'terraform apply tfplan'
                }
            }
        }
        stage('Clean up') {
            steps {
                script {
                    // Clean up (if needed)
                    sh 'rm -rf .terraform* tfplan'
                }
            }
        }
    }
    post {
        always {
            // Notify or take actions after the pipeline is done (e.g., cleanup)
            echo 'Pipeline finished.'
        }
    }
}
