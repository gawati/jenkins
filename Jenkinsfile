pipeline {
    agent any

    environment { 
        // CI="false"
        DLD="/var/www/html/dl.gawati.org/dev"
        PKF="jenkinstest"
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
                sh 'echo MYTEST=\\\"Preload through shell environment.\\\" >>.bashrc'
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
                    // def packageFile = readJSON file: 'package.json'
                    sh "cd build ; tar -cvjf $DLD/$PKF-${GIT_COMMIT}.tbz ."
                    sh "cd build ; zip -r - . > $DLD/$PKF-${GIT_COMMIT}.zip"
                    //sh "[ -L $DLD/$PKF-latest.zip ] && rm -f $DLD/$PKF-latest.zip ; exit 0"
                    //sh "[ -e $DLD/$PKF-latest.zip ] || ln -s $PKF-${packageFile.version}.zip $DLD/$PKF-latest.zip"
                    //sh "[ -L $DLD/$PKF-latest.tbz ] && rm -f $DLD/$PKF-latest.tbz ; exit 0"
                    //sh "[ -e $DLD/$PKF-latest.tbz ] || ln -s $PKF-${packageFile.version}.tbz $DLD/$PKF-latest.tbz"
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

