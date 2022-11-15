pipeline {
    agent any
    options {disableConcurrentBuilds()}
    environment {
        GOOGLE_PROJECT_ID = "vinaydevops" 
        GOOGLE_PROJECT_NAME = "vinaydevops"
        CREDENTIALS_ID = credentials('sc_jenkins_terraform')
     }
    parameters { 
      choice(name: 'ENTER', choices: ['dev', 'pre', 'pro'], description: 'Select the environment')
      choice(name: 'ACTION', choices: ['', 'plan-apply', 'destroy'], description: 'Select the action')
    }
	tools {
        terraform 'jenkins_terraform'
    }
	
    stages{
         stage ("terraform init") {
            steps {
                sh 'terraform init'
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
        
        stage('Confirm the Action') {
            steps {
                script {
                    def userInput = input(id: 'confirm', message: params.ACTION + '?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                }
            }
        }
        
        stage('Terraform apply or destroy ----------------') {
            steps {
               sh 'echo "Deployment pipeline"'
            script{  
                if (params.ACTION == "destroy"){
                       sh 'terraform destroy -auto-approve'
                } else {
                        sh 'terraform apply -auto-approve'  
                }  // if

            }
            } 
        }  
   }  
} 
