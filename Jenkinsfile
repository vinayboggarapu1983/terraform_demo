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
                 'terraform init'
            }
        }
        stage ("terraform fmt") {
            steps {
                 'terraform fmt'
            }
        }
        stage ("terraform validate") {
            steps {
                 'terraform validate'
            }
        }
        stage ("terrafrom plan") {
            steps {
                 'terraform plan'
            }
        }
        
     stage ("terrafrom apply") {
            steps {
               'terraform apply -auto-approve'
            }
        }
        
  }  
} 
