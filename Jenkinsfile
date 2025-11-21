// Jenkinsfile reutilizable para QA y PROD
def API_CONTAINER_NAME = 'certamen-app-container'
def API_IMAGE_NAME = 'certamen-app-image'

pipeline {
    agent any
    
    // Parámetros que usaremos para diferenciar QA de PROD
    parameters {
        string(name: 'GIT_BRANCH', defaultValue: 'qa', description: 'Rama a construir (qa o main)')
        booleanParam(name: 'FAIL_ON_QG_FAIL', defaultValue: false, description: 'True para PROD (bloquear), False para QA (continuar)')
        string(name: 'DEPLOY_PORT', defaultValue: '9001:3000', description: 'Puerto de despliegue (HOST:CONTAINER)')
    }

    stages {
        stage('Descargar Código') {
            steps {
                // Descargar el código del repositorio desde la rama qa o main
                git branch: params.GIT_BRANCH, url: 'https://github.com/seba1012/certamen2_cicd.git' 
            }
        }
        stage('Revisión SonarQube') {
            steps {
                script {
                    def projectKey = params.GIT_BRANCH == 'main' ? 'certamen2_prod' : 'certamen2_qa'
                    // Llama al servidor configurado 'SonarQube_Local'
                    withSonarQubeEnv('SonarQube_Local') {
                        sh "sonar-scanner -Dsonar.projectKey=${projectKey} -Dsonar.sources=."
                    }
                }
            }
        }
        stage('Quality Gate Check') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    // Controla el comportamiento: continuar (QA) o fallar (PROD)
                    waitForQualityGate abortPipeline: params.FAIL_ON_QG_FAIL 
                }
            }
        }
        stage('Construir y Desplegar') {
            steps {
                // Eliminar instancia original
                sh "docker stop ${API_CONTAINER_NAME}-${params.GIT_BRANCH} || true"
                sh "docker rm ${API_CONTAINER_NAME}-${params.GIT_BRANCH} || true"
                
                // Construir el contenedor (usa el Dockerfile)
                sh "docker build -t ${API_IMAGE_NAME}-${params.GIT_BRANCH} ."
                
                // Desplegar la solución
                sh "docker run -d --name ${API_CONTAINER_NAME}-${params.GIT_BRANCH} -p ${params.DEPLOY_PORT} ${API_IMAGE_NAME}-${params.GIT_BRANCH}"
            }
        }
        stage('Mostrar Logs') {
            steps {
                // Mostrar el log del contenedor de la API
                sh "docker logs ${API_CONTAINER_NAME}-${params.GIT_BRANCH}"
            }
        }
    }
}