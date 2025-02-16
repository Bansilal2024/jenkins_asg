pipeline {
    agent any
    environment {
        TF_VERSION = '1.0.11'  // specify your Terraform version
        AWS_REGION = "ap-southeast-1"
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')  // Store AWS credentials in Jenkins credentials manager
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
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
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                input 'Approve the Apply?'  // Manual approval step before applying changes
                script {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Clean up') {
            steps {
                script {
                    sh 'rm -rf .terraform* tfplan'
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
