pipeline {
    agent any

    environment { 
        // CI="false"
        DLD="/tmp"
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
                sh '(set -o posix; set)'
            }
        }
        stage('Upload') {
            steps {
                script {
                    sh """
cd library
. ./jenkinslib.sh
PkgProvide
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

