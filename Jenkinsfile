pipeline {
    agent any

//  define {
//      def COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']
//      def STATUS_MAP = ['SUCCESS': 'success', 'FAILURE': 'failed', 'UNSTABLE': 'failed', 'ABORTED': 'failed']
//  }

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
pushd library >/dev/null
PkgPack
PkgLinkLatest
popd >/dev/null
./rebuild_bundlelinks.sh
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

