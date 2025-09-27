pipeline {
  agent any
  options { timestamps() }
  environment {
    APP_IMAGE = 'george524/mag-app'
    APP_PORT  = '5000'
  }

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Unit Tests') {
      steps {
        dir('application') {
          sh '''
            set -e
            echo "Contents of application/:"
            ls -la

            docker run --rm \
              -v "$PWD":/app -w /app \
              python:3.12-slim \
              /bin/sh -s <<'PYTEST'
set -e
if [ -f requirements.txt ]; then
  echo "Using requirements.txt"
  pip install --no-cache-dir -r requirements.txt
else
  echo "requirements.txt not found — installing minimal deps"
  pip install --no-cache-dir flask==3.0.3 pytest==8.3.2 requests==2.32.3
fi

# Run pytest; allow exit code 5 (no tests collected), fail on others
pytest -q || code=$?
if [ "${code:-0}" -eq 5 ]; then
  echo "No tests collected — continuing"
  exit 0
fi
exit "${code:-0}"
PYTEST
          '''
        }
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
          docker rm -f mag-app-test || true
          docker run -d --name mag-app-test ${APP_IMAGE}:${BUILD_NUMBER}
          TARGET_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mag-app-test)
          for i in {1..30}; do
            curl -fsS "http://$TARGET_IP:${APP_PORT}/health" && break
            sleep 1
          done
          curl -v --fail "http://$TARGET_IP:${APP_PORT}/health"
        '''
      }
      post {
        always {
          sh 'docker logs mag-app-test || true; docker rm -f mag-app-test || true'
        }
      }
    }

    stage('Push (optional)') {
      when { branch 'main' }
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-hub-creds',
          usernameVariable: 'DOCKERHUB_USER',
          passwordVariable: 'DOCKERHUB_PASS'
        )]) {
          sh '''
            set -e
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
            SHORT_SHA=$(git rev-parse --short=7 HEAD)
            docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:${SHORT_SHA}
            docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:latest
            docker push ${APP_IMAGE}:${BUILD_NUMBER}
            docker push ${APP_IMAGE}:${SHORT_SHA}
            docker push ${APP_IMAGE}:latest
            docker logout || true
          '''
        }
      }
    }

    stage('Deploy (main)') {
      when { branch 'main' }
      steps {
        sh '''
          set -e
          docker rm -f mag-app || true
          docker pull ${APP_IMAGE}:latest
          docker run -d --name mag-app -p 80:5000 ${APP_IMAGE}:latest
          for i in {1..20}; do
            curl -fsS http://localhost/health && break
            sleep 1
          done
          curl -v --fail http://localhost/health
        '''
      }
    }
  }

  post {
    success { echo "SUCCESS: Built, tested, pushed & deployed ${APP_IMAGE}:${BUILD_NUMBER}" }
    failure { echo "FAILED: Check logs" }
  }
}
