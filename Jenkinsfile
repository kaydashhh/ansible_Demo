pipeline{
  agent any  
  stages{  
     
      stage('Git checkout') {
            steps {
                git branch: 'main', credentialsId: '', url: 'https://github.com/kaydashhh/ansible_Demo.git'
            }
        }
      stage("Run an ansible playbook"){
        steps{
          ansiblePlaybook credentialsId: 'SSH-KEY', disableHostKeyChecking: true, inventory: 'hosts', playbook: 'nginx_install.yaml'
          //ansiblePlaybook become: true, disableHostKeyChecking: true, inventory: 'hosts', playbook: 'nginx_install.yaml', vaultCredentialsId: 'SSH-KEY'
        }
      }
      stage("Print Installation Is Complete"){
        steps{
           sh"echo Your Installation Was Successful  On All Servers"
        }
      }
  }
}
