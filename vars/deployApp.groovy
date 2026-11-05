
def call(Map config) {
    echo "Deploying ${config.appName} to ${config.environment}"

    sh """
        echo 'Deployment started for ${config.appName}'
        echo 'Environment: ${config.environment}'
        echo 'Version: ${config.version}'
        sleep 5
        echo 'Deployment completed successfully'
    """
}
