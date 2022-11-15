pipeline {
    agent any
    environment {
	PROJECT_ID = "vinaydevops" 
        CREDENTIALS_ID = credentials('sc_jenkins_terraform')
     }
   	tools {
        terraform 'jenkins_terraform'
    }
	
    stages{
         stage ("terraform init") {
            steps {
                sh 'cd terraform && terraform init'
            }
        }
        stage ("terraform fmt") {
            steps {
                sh 'cd terraform && terraform fmt'
            }
        }
        stage ("terraform validate") {
            steps {
                sh 'cd terraform && terraform validate'
            }
        }
        stage ("terrafrom plan") {
            steps {
                sh 'cd terraform && terraform plan'
            }
        }
        
     stage ("terrafrom apply") {
            steps {
              sh 'cd terraform && terraform apply -auto-approve'
            }
        }
        
  }  
} 
