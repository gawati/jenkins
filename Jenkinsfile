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
                sh 'ls -la'
                sh '(set -o posix; set)'
            }
        }
        stage('Setup') {
            steps {
                sh 'echo MYTEST=\\\"Preload through shell environment.\\\" >.profile'
            }
        }
        stage('Build') {
            steps {
                sh 'echo "MYTEST: >${MYTEST}<"'
            }
        }
        stage('Upload') {
            steps {
                script {
                    def PkgJsn = readJSON file: 'package.json'
                    sh """
(set -o posix; set)
tar -cvjf ${DLD}/${PkgJsn.name}-${GIT_COMMIT}.tbz .
[ -L "${DLD}/${PkgJsn.name}-latest.tbz" ] && rm -f "${DLD}/${PkgJsn.name}-latest.tbz"
[ -e "${DLD}/${PkgJsn.name}-latest.tbz" ] || ln -s "${PkgJsn.name}-${GIT_COMMIT}.tbz" "${DLD}/${PkgJsn.name}-latest.tbz"
[ -L "${DLD}/${PkgJsn.name}-${PkgJsn.version}.tbz" ] && rm -f "${DLD}/${PkgJsn.name}-${GIT_COMMIT}.tbz"
[ -e "${DLD}/${PkgJsn.name}-${PkgJsn.version}.tbz" ] || ln -s "${PkgJsn.name}-${GIT_COMMIT}.tbz" "${DLD}/${PkgJsn.name}-${PkgJsn.version}.tbz"
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

