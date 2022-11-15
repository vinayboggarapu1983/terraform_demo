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
               sh  'terraform init'
            }
        }
        stage ("terraform fmt") {
            steps {
                 sh 'terraform fmt'
            }
        }
        stage ("terraform validate") {
            steps {
                 sh 'terraform validate'
            }
        }
        stage ("terrafrom plan") {
            steps {
                 sh 'terraform plan'
            }
        }
        
     stage ("terrafrom apply") {
            steps {
               sh 'terraform destroy -auto-approve'
            }
        }
        
  }  
} 
