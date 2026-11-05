pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_TARGET', choices: ['current-instance', 'all-instances'], description: 'Deployment Target')
        booleanParam(name: 'RUN_HEALTH_CHECK', defaultValue: true, description: 'Run Health Check')
    }