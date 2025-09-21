pipeline {
  agent any
  options { timestamps() }

  environment {
    APP_IMAGE = 'george524/mag-app'          // <-- change to your Docker Hub repo
    APP_PORT  = '5000'
    DOCKER_CRED = credentials('docker-hub-creds') // Jenkins cred ID (username+password/token)
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Image') {
      steps {
        dir('application') {
          sh 'docker build -t ${APP_IMAGE}:${BUILD_NUMBER} .'
        }
      }
    }

    stage('Test') {
      steps {
        sh '''
          docker rm -f mag-app-test || true
          docker run -d --name mag-app-test -p ${APP_PORT}:${APP_PORT} ${APP_IMAGE}:${BUILD_NUMBER}
          # basic ping test
          sleep 3
          curl --fail http://localhost:${APP_PORT}/health
        '''
      }
      post {
        always { sh 'docker rm -f mag-app-test || true' }
      }
    }

    stage('Push (optional)') {
      when { branch 'main' }
      steps {
        sh '''
          echo "$DOCKER_CRED_PSW" | docker login -u "$DOCKER_CRED_USR" --password-stdin
          docker push ${APP_IMAGE}:${BUILD_NUMBER}
          docker logout || true
        '''
      }
    }
  }

  post {
    success { echo "SUCCESS: Built ${APP_IMAGE}:${BUILD_NUMBER}" }
    failure { echo "FAILED: Check logs" }
  }
}
