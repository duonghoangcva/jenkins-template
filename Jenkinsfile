pipeline {
    agent any
//    options {
//        // This is required if you want to clean before build
//        skipDefaultCheckout(true)
//    }
    parameters {
        // string(name: 'BUCKET_NAME', description: 'Enter the bucket name')
        string(name: 'VM_INSTANCE_IP', description: 'Enter the vm name')
        // string(name: 'DOCKER_IMAGE_NAME', description: 'Enter the docker image name')
        // string(name: 'DOCKER_CONTAINER_NAME', description: 'Enter the bucket name')
        string(name: 'EMAIL_RECIPIENT', description: 'Email address to receive the notification')
        string(name: 'BRANCH', description: 'Deploy Branch')
        // string(name: 'S3_BUCKET_NAME', description: 'Deploy Bucket Name')
        // string(name: 'EC2_INSTANCE_NAME', description: 'Deploy EC2 Name')
        // string(name: 'STACK_NAME', description: 'Deploy Stack Name')

    }

    stages {
        stage('Clean up build env linux') {
        agent { 
            label 'linux-agent'
        }            
            steps {
                cleanWs()
        }
        }
        stage('Checkout Linux') {
        agent { 
            label 'linux-agent'
        }            
            steps {
                git branch: 'main', credentialsId: 'jenkins-ssh', url: 'https://github.com/duonghoangcva/jenkins-template.git'            } 
        }
        stage('Checkout Local') {
        agent { 
            label 'local'
        }            
            steps {
                git branch: 'main', credentialsId: 'jenkins-ssh', url: 'https://github.com/duonghoangcva/jenkins-template.git'            } 
        }
        // stage('Clean up build env windows') {
        // agent { 
        //     label 'windows-slave'
        // }            
        //     steps {
        //         cleanWs()
        //     }        
        // }
        // stage('Checkout Windows') {
        // agent { 
        //     label 'windows-slave'
        // }            
        //     steps {
        //         git branch: params.BRANCH, credentialsId: '95598b0f-5f34-4404-bbed-657578cc4fc3', url: 'https://github.com/luuthanhtu020296/jenkins-template.git'            } 
        // }        
        stage('Build') {
        agent { 
            label 'linux-agent'
        }            
            steps {
                script {
                    // Perform any build steps if needed
                    sh "ls -l -a"
                }
            }
        }
        // stage('Login to az') {
        //     steps {
        //         withCredentials([azureServicePrincipal('azkey')]) {
        //                   sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
        //                   sh 'az account set -s $AZURE_SUBSCRIPTION_ID'
        //                   sh 'az resource list'
        //         }
        //     }
        // stage('Deploy to Blob') {
        //     steps {
        //         sh 'pwd'
        //         sh 'chmod +x ./azblob.sh'
        //         sh './azblob.sh'
        //         // sh 'cat /home/ec2-user/work/workspace/demo-tos3/index.html'
        //     }
        // }
        
        stage('Install Docker') {
        agent { 
            label 'linux-agent'
        }            
            steps {
                script {
                    // SSH into VM instance and run the Docker container
                    sshagent(['minikey']) {
                        // sh '''
                        //   [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh
                        //   ssh-keyscan -t rsa,dsa ${VM_INSTANCE_IP} >> ~/.ssh/known_hosts
                        //   ssh azureuser@${VM_INSTANCE_IP}
                        //   '''
                        // sh 'ssh azureuser@${VM_INSTANCE_IP} sudo mkdir /home/azureuser/deploy'
                        sh 'pwd'
                        sh """
                            scp ./linux_install_guilde_docker/install-docker-ubuntu.sh azureuser@${VM_INSTANCE_IP}:/home/azureuser/deploy/
                        """
                        sh """ssh azureuser@${VM_INSTANCE_IP} '. /home/azureuser/deploy/install-docker-ubuntu.sh'"""
                    }
                }
            }
        }
        stage('Deploy Web Application with Docker Compose') {
        agent { 
            label 'linux-agent'
        }            
            steps {
                script {
                    // Copy Docker Compose file to the EC2 instance
                    sshagent(['minikey']) {
                        sh """scp docker-compose.yml azureuser@${VM_INSTANCE_IP}:/home/azureuser/deploy/"""
                    }
                    // Copy nginx config file to the EC2 instance
                    sshagent(['minikey']) {
                        sh """scp nginx.conf azureuser@${VM_INSTANCE_IP}:/home/azureuser/deploy"""
                    } 
                    // Copy html file to the EC2 instance
                    sshagent(['minikey']) {
                        sh """scp index.html azureuser@${VM_INSTANCE_IP}:/home/azureuser/deploy"""
                    }                     
                    // Deploy the web application using Docker Compose on the EC2 instance
                    sshagent(['minikey']) {
                        sh """ssh azureuser@${VM_INSTANCE_IP} 'cd /home/azureuser/deploy/ && docker compose -f docker-compose.yml up -d'"""
                    }
                }
            }
        }
        stage('Scan with localhost') {
        agent { 
            label 'local'
        }            
            steps {
                // bat 'cd JenkinsWebApplicationDemo && sonar-scanner -Dsonar.projectKey=testc -Dsonar.sources=. -Dsonar.host.url=http://localhost:9000 -Dsonar.login=squ_f09ad1c0fd77e0d30e72876858242610c06ae80e'
                sh 'pwd'
                sh 'ls'
                sh 'docker run --rm --network host -v `pwd`:/app --workdir="/app" sonarsource/sonar-scanner-cli sonar-scanner -X $SONAR_SCANNER_OPTS -Dsonar.host.url="http://localhost:80" -Dsonar.login="sqa_d959bc3d1ae916a432cf138bfddeee4b192b0c22" -Dsonar.sources="notes_app/" -Dsonar.projectKey="test-project" -Dsonar.projectName="test-project" -Dsonar.projectVersion="v1.0.0"'
            }
        }        
        stage('Slack Notify') {
        agent { 
            label 'local'
        }            
            steps {
                slackSend channel: 'pratice', message: 'test'
            }
        }
        // stage('Build and Test') {
        //     parallel {
        //         stage('Build and Test on main') {
        //         agent { 
        //             label 'local'
        //         }                      
        //             when {
        //                     expression { params.BRANCH == 'main' }
        //             }
        //             steps {
        //                 withCredentials([azureServicePrincipal('azkey')]) {
        //                     sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
        //                     sh 'az account set -s $AZURE_SUBSCRIPTION_ID'
        //                     sh 'az resource list'
        //                 } 
        //                 // {
        //                 //     // sh """aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://template.yaml --parameters ParameterKey=InstanceName,ParameterValue=${EC2_INSTANCE_NAME}"""
        //                 // }
        //             }
        //         }

        //         stage('Build and Test on Dev') {
        //         agent { 
        //             label 'local'
        //         }                     
        //             when {
        //                 expression { params.BRANCH == 'dev' }
        //             }
        //             steps {
        //                 withCredentials([azureServicePrincipal('azkey')]) {
        //                     sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
        //                     sh 'az account set -s $AZURE_SUBSCRIPTION_ID'
        //                     sh 'az resource list'
        //                 } 
        //                 // {
        //                 //     // sh """aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://template.yaml --parameters ParameterKey=BucketName,ParameterValue=${S3_BUCKET_NAME}"""
        //                 // }
        //             }
        //         }
        //     }
        // }
    }   
    post {
         always {  
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }  
         success {  
            script {
                // Send email on success build
                emailext subject: 'Jenkins Build Success',
                          body: 'The Jenkins build Success',
                          to: params.EMAIL_RECIPIENT,
                          replyTo: '',
                          mimeType: 'text/html'
            }
        }  
         failure {  
            script {
                // Send email on failed build
                emailext subject: 'Jenkins Build Failure',
                          body: 'The Jenkins build failed. Please check the Jenkins console for details.',
                          to: params.EMAIL_RECIPIENT,
                          replyTo: '',
                          mimeType: 'text/html'
            }
         }  
         unstable {  
             echo 'This will run only if the run was marked as unstable'  
         }  
         changed {  
             echo 'This will run only if the state of the Pipeline has changed'  
             echo 'For example, if the Pipeline was previously failing but is now successful'  
         } 
    }      
}
