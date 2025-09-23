pipeline {
  agent any
  options { timestamps() }

  environment {
    APP_IMAGE = 'george524/mag-app'   // Docker Hub repo
    APP_PORT  = '5000'                // App listens on this inside the container
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
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
          set -e
          echo "=== MAG TEST STAGE v3 (container IP) ==="

          # Clean previous run
          docker rm -f mag-app-test || true

          # Start the app container (no host port mapping needed)
          docker run -d --name mag-app-test ${APP_IMAGE}:${BUILD_NUMBER}

          # Get the container's IP on the bridge network
          TARGET_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mag-app-test)
          echo "Container IP: $TARGET_IP"

          echo "Waiting for http://$TARGET_IP:${APP_PORT}/health ..."

          # Retry up to 30s
          for i in {1..30}; do
            if curl -fsS "http://$TARGET_IP:${APP_PORT}/health" > /dev/null; then
              echo "App is up and healthy!"
              break
            fi
            sleep 1
          done

          # Final assert (verbose)
          curl -v --fail "http://$TARGET_IP:${APP_PORT}/health"
        '''
      }
      post {
        always {
          sh '''
            echo "=== Container logs (mag-app-test) ==="
            docker logs mag-app-test || true
            docker rm -f mag-app-test || true
          '''
        }
      }
    }

    stage('Push (optional)') {
      

      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-hub-creds',
          usernameVariable: 'DOCKERHUB_USER',
          passwordVariable: 'DOCKERHUB_PASS'
        )]) {
          sh '''
            set -e

            # Login to Docker Hub
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin

            # Tag extras (latest and short SHA)
            SHORT_SHA=$(git rev-parse --short=7 HEAD)
            docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:latest
            docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:${SHORT_SHA}

            # Push with a simple retry for network hiccups
            for TAG in ${BUILD_NUMBER} ${SHORT_SHA} latest; do
              docker push ${APP_IMAGE}:$TAG || { echo "Retrying push ${APP_IMAGE}:$TAG ..."; sleep 2; docker push ${APP_IMAGE}:$TAG; }
            done

            docker logout || true
          '''
        }
      }
    }
  }

  post {
    success { echo "SUCCESS: Built and tested ${APP_IMAGE}:${BUILD_NUMBER}" }
    failure { echo "FAILED: Check logs" }
  }
}
