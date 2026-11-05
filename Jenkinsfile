
pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_TARGET', choices: ['current-instance', 'all-instances'], description: 'Deployment Target')
        booleanParam(name: 'RUN_HEALTH_CHECK', defaultValue: true, description: 'Run Health Check')
    }

    environment {
        INSTANCE_ID = 'unknown'
        BRANCH_TYPE = 'other'
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    env.INSTANCE_ID = sh(
                        script: '''
                            TOKEN=$(curl -fsS -m 3 -X PUT \
                              -H "X-aws-ec2-metadata-token-ttl-seconds: 60" \
                              http://169.254.169.254/latest/api/token) || exit 0

                            curl -fsS -m 3 \
                              -H "X-aws-ec2-metadata-token: $TOKEN" \
                              http://169.254.169.254/latest/meta-data/instance-id
                        ''',
                        returnStdout: true
                    ).trim() ?: 'unknown'

                    def branch = env.BRANCH_NAME ?: ''

                    env.BRANCH_TYPE =
                        branch.startsWith('feature/') ? 'feature' :
                        branch == 'ec2-development' ? 'development' :
                        branch == 'ec2-staging' ? 'staging' :
                        branch == 'main' ? 'production' : 'other'
                }

                echo "Branch: ${env.BRANCH_NAME}"
                echo "Branch Type: ${env.BRANCH_TYPE}"
                echo "Instance ID: ${env.INSTANCE_ID}"
                echo "Deploy Target: ${params.DEPLOY_TARGET}"
            }
        }

        stage('Validate Scripts') {
            steps {
                sh '''
                    echo "=== Script Validation for ${BRANCH_TYPE} ==="

                    for script in *.sh; do
                        if [ -f "$script" ]; then
                            bash -n "$script" || exit 1
                            echo "OK: $script"
                        fi
                    done
                '''
            }
        }

        stage('Test Scripts') {
            when {
                expression { params.RUN_HEALTH_CHECK == true }
            }

            parallel {
                stage('Syntax Tests') {
                    steps {
                        sh '''
                            echo "Running syntax tests..."
                            bash -n ec2-info.sh && echo "ec2-info.sh syntax OK"
                            bash -n ec2-health.sh && echo "ec2-health.sh syntax OK"
                        '''
                    }
                }

                stage('Functionality Tests') {
                    steps {
                        sh '''
                            echo "Running functionality tests..."
                            chmod +x *.sh
                            timeout 30 ./ec2-info.sh > /tmp/test-output.txt
                            echo "Test completed"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Development') {
            when {
                anyOf {
                    branch 'ec2-development'
                    branch 'feature/*'
                }
            }

            steps {
                echo "Deploying to development environment"

                sh '''
                    mkdir -p /opt/ec2-scripts/dev
                    cp *.sh /opt/ec2-scripts/dev/
                    echo "Development deployment completed"
                '''
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'ec2-staging'
            }

            steps {
                echo "Deploying to staging environment"

                sh '''
                    mkdir -p /opt/ec2-scripts/staging
                    cp *.sh /opt/ec2-scripts/staging/
                    echo "Staging deployment completed"
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }

            steps {
                input message: 'Deploy to Production Instance?', ok: 'Deploy'

                echo "Deploying to production environment"

                sh '''
                    mkdir -p /opt/ec2-scripts/prod
                    cp *.sh /opt/ec2-scripts/prod/
                    chmod +x /opt/ec2-scripts/prod/*.sh
                    echo "Production deployment completed on ${INSTANCE_ID}"
                '''
            }
        }
    }

    post {
        always {
            echo "EC2 Pipeline completed for branch: ${env.BRANCH_NAME}"
            archiveArtifacts artifacts: '*.sh', allowEmptyArchive: true
        }

        success {
            echo "Pipeline succeeded on instance ${env.INSTANCE_ID}!"
        }

        failure {
            echo "Pipeline failed on instance ${env.INSTANCE_ID}!"
        }
    }
}
