pipeline {
    agent any

    environment { 
        // CI="false"
        DLD="/var/www/html/dl.gawati.org/dev"
    } 

//  define {
//      def COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']
//      def STATUS_MAP = ['SUCCESS': 'success', 'FAILURE': 'failed', 'UNSTABLE': 'failed', 'ABORTED': 'failed']
//  }

    tools {nodejs "nodejs-lts"}
     
    stages {
        stage('Prerun Diag') {
            steps {
                sh 'pwd'
            }
        }
        stage('Setup') {
            steps {
                sh 'ls -la'
            }
        }
        stage('Build') {
            steps {
                sh '#(set -o posix; set)'
            }
        }
        stage('Upload') {
            steps {
                script {
                    sh """
. ./library/jenkinslib.sh
cd library
PkgPack
"""
                }
            }
        }
        stage('Clean') {
            steps {
                cleanWs(cleanWhenAborted: true, cleanWhenNotBuilt: true, cleanWhenSuccess: true, cleanWhenUnstable: true, cleanupMatrixParent: true, deleteDirs: true)
            }
        }        
    }
}

