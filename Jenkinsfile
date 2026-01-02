pipeline {
  agent any

  environment {
    HARBOR_CREDENTIAL = 'harbor-registry'
    HARBOR_REGISTRY = 'harbor.cnte.com'
    NEXUS_URL = 'http://nexus.cnte.com:8081'
    NEXUS_CREDENTIAL = 'nexus-repo'
    PROJECT_VERSION = '3.4.1'
  }

  tools {
    maven "M3"
  }

  stages {
    stage('Git Clone Projet') {
      steps {
        git branch: 'master', url: 'https://github.com/brahimhamdi/petclinic-microservices'
      }
    }

    stage('Build Projet') {
      steps {
        sh 'mvn clean compile'
      }
    }

    stage('Tests') {
      steps {
        sh 'mvn test'
      }
      post {
        always {
          junit '**/target/surefire-reports/TEST-*.xml'
        }
      }
    }

    stage('Analyse SonarQube') {
      steps {
        withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
          sh """
            mvn clean verify sonar:sonar \
            -Dsonar.projectKey=Petclinic-Microservices \
            -Dsonar.projectName="Spring PetClinic Microservices" \
            -Dsonar.host.url=http://192.168.56.120:9000 \
            -Dsonar.login=${SONAR_TOKEN}
          """
        }
      }
    }

    stage('Package') {
      steps {
        sh 'mvn package -DskipTests'
      }
    }
    
    stage('Déploiement Artifacts sur Nexus') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: NEXUS_CREDENTIAL,
          usernameVariable: 'NEXUS_USER',
          passwordVariable: 'NEXUS_PASS'
        )]) {
          script {
            def modules = ['customers-service', 'vets-service', 'visits-service', 
                          'config-server', 'discovery-server', 'api-gateway']
            
            modules.each { module ->
              dir(module) {
                echo "Traitement du module: ${module}"
                
                // Extraire artifactId du pom.xml
                def artifactId = sh(script: """
                  if [ -f pom.xml ]; then
                    grep -oP '(?<=<artifactId>)[^<]+' pom.xml | head -1 || echo "${module}"
                  else
                    echo "${module}"
                  fi
                """, returnStdout: true).trim()
                
                echo "ArtifactId détecté: ${artifactId}"
                
                // Chercher le fichier JAR
                def jarFile = sh(script: """
                  find target -name "*.jar" -type f 2>/dev/null | head -1
                """, returnStdout: true).trim()
                
                if (jarFile && fileExists(jarFile)) {
                  def jarName = sh(script: "basename ${jarFile}", returnStdout: true).trim()
                  
                  echo "Déploiement de ${jarName} vers Nexus..."
                  
                  sh """
                    curl -f -u ${NEXUS_USER}:${NEXUS_PASS} \
                      --upload-file ${jarFile} \
                      ${NEXUS_URL}/repository/petclinic-releases/org/springframework/samples/${artifactId}/${PROJECT_VERSION}/${jarName}
                  """
                  
                  echo "${jarName} déployé sur Nexus"
                } else {
                  echo "Aucun fichier JAR trouvé dans ${module}/target/"
                }
              }
            }
          }
        }
      }
    }

    stage('Build Images Docker') {
      steps {
        script {
                // Construire l'image avec le profil buildDocker
                sh """
                  mvn clean install -P buildDocker -DskipTests
                """
              }
          }
        }

    stage('Test Images Docker') {
      steps {
        script {
          def modules = ['customers-service', 'vets-service', 'visits-service', 
                        'config-server', 'discovery-server', 'api-gateway']
          
          modules.each { module ->
            dir(module) {
              if (fileExists('src/main/resources/application.yml')) {
                echo "Test de l'image Docker pour ${module}"
                
                // Vérifier que l'image a été construite
                def imageName = "harbor.cnte.com/petclinic/${module}:latest"
                def imageCheck = sh(script: """
                  docker images -q ${imageName} 2>/dev/null || echo ""
                """, returnStdout: true).trim()
                
                if (imageCheck) {
                  echo "Image ${imageName} trouvée"
                  
                  // Test simple: vérifier la taille de l'image
                  sh """
                    echo "=== Informations de l'image ==="
                    docker image inspect ${imageName} --format 'Image: {{.RepoTags}}\nTaille: {{.Size}} bytes\nDate: {{.Created}}'
                  """
                  
                  // Tester en lançant un conteneur temporaire
                  sh """
                    echo "=== Test de lancement du conteneur ==="
                    timeout 30s docker run --rm ${imageName} --version 2>&1 | head -5 || true
                  """
                  
                } else {
                  echo "Image ${imageName} non trouvée"
                }
              }
            }
          }
        }
      }
    }

    stage('Push Images Docker') {
      steps {
        script {
          def modules = ['customers-service', 'vets-service', 'visits-service', 
                        'config-server', 'discovery-server', 'api-gateway']
          
          modules.each { module ->
            dir(module) {
              if (fileExists('src/main/resources/application.yml')) {
                echo "Push de l'image Docker pour ${module}"
                
                // Noms des images
                def sourceImage = "harbor.cnte.com/petclinic/${module}:latest"
                def harborImageVersion = "${HARBOR_REGISTRY}/petclinic/${module}:${PROJECT_VERSION}"
                def harborImageLatest = "${HARBOR_REGISTRY}/petclinic/${module}:latest"
                
                // Taguer les images pour Harbor
                sh """
                  docker tag ${sourceImage} ${harborImageVersion}
                  docker tag ${sourceImage} ${harborImageLatest}
                """
                
                // Push vers Harbor
                withCredentials([usernamePassword(
                  credentialsId: HARBOR_CREDENTIAL,
                  usernameVariable: 'HARBOR_USER',
                  passwordVariable: 'HARBOR_PASS'
                )]) {
                  sh """
                    docker login ${HARBOR_REGISTRY} -u ${HARBOR_USER} -p ${HARBOR_PASS}
                    docker push ${harborImageVersion}
                    docker push ${harborImageLatest}
                  """
                }
                
                echo "${module}: ${harborImageVersion} poussée vers Harbor"
                
                // Nettoyage des images temporaires
                sh """
                  docker rmi ${sourceImage} 2>/dev/null || true
                """
              }
            }
          }
        }
      }
    }

 stage('Deploy Env Prod - k8s cluster - Manual') {
      steps {
        script {
          timeout(time: 30, unit: 'MINUTES') {
            input message: 'Voulez-vous lancer le déploiement sur le cluster kubernetes ?', ok: 'Yes'
          }

          withCredentials([usernamePassword(
            credentialsId: 'ssh-env-prod-password',
            usernameVariable: 'SSH_USER',
            passwordVariable: 'SSH_PASS'
          )]) {

            sh """
              sshpass -p '${SSH_PASS}' scp -o StrictHostKeyChecking=no petclinic-microservices-k8s.yaml ${SSH_USER}@192.168.56.10:/tmp/
              sshpass -p '${SSH_PASS}' ssh -o StrictHostKeyChecking=no ${SSH_USER}@192.168.56.10 'kubectl apply -f /tmp/petclinic-microservices-k8s.yaml'
            """
          }
        }
      }
    }
  }
}


