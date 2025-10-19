// 1. Mandatory wrapper for Scripted Pipeline
node {
    // 2. Global environment variables (using 'env' prefix is common in Scripted)
    env.DB_TARGET = 'QA_SQL_SERVER_INSTANCE'
    // Load credential ID into an environment variable
    env.DB_USER   = credentials('etl-svc-user') 

    try {
        // --- Stage 1: Checkout the Code ---
        stage('Checkout Source') {
            // Ensure the repository is checked out. 
            git url: 'https://github.com/crazy-mom/PFDM-ETL-Repo.git', branch: 'main'
        }

        // --- Stage 2: Execute Core ETL Process (The E and L) ---
        stage('Run ETL Job') {
            echo 'Starting ETL process: Extracting and Loading Patient Bills...'
            // The pipeline will automatically stop and jump to the 'catch' block if this shell command fails (non-zero exit code).
            sh 'python3 etl_script.py --target ${env.DB_TARGET}'
        }

        // --- Stage 3: Automated Data Quality Check (The QA Step) ---
        stage('Data Quality Validation') {
            echo 'Running automated data quality checks...'
            // This command must return a non-zero exit code on failure to stop the pipeline.
            sh 'python3 qa_validation_script.py --check rounding'
        }

    } catch (err) {
        // 4. Handle Failure: This 'catch' block executes on any failure in Stage 2 or 3.
        
        // Immediate CRITICAL FAILURE notification (Replicates Stage 2 post-failure)
        stage('Failure Alert: Core ETL') {
            emailext (
                to: 'gnayyar06@gmail.com',
                subject: "CRITICAL FAILURE: PFDM ETL Load",
                body: "The ETL job failed in Stage 2 or 3. Check Jenkins console log for details at ${env.BUILD_URL}"
            )
        }
        
        // DQ ALERT notification (Replicates Final failure post-action)
        stage('Failure Alert: Data Quality') {
            emailext (
                to: 'qa-team@company.com', 
                subject: "DQ ALERT: PFDM Rounding Error Detected (Build ${env.BUILD_NUMBER})", 
                body: "A critical stage FAILED. Investigate the DW_Bills table immediately. Build URL: ${env.BUILD_URL}"
            )
        }

        // Mark the build as failure and re-throw the error to ensure the build status is correct.
        currentBuild.result = 'FAILURE'
        throw err

    } finally {
        // 5. Cleanup and Final Notifications: This 'finally' block ALWAYS runs.
        
        stage('Final Notifications & Cleanup') {
            // Always archive test results
            junit 'test-results/validation-results.xml' 

            // Check if the build was successful (result is null until explicitly set)
            if (currentBuild.result == 'SUCCESS' || currentBuild.result == null) {
                // SUCCESS: (Replicates Final success post-action)
                emailext (
                    to: 'data-ops@company.com', 
                    subject: "SUCCESS: PFDM Daily Load Complete (Build ${env.BUILD_NUMBER})", 
                    body: "The ETL job completed and passed all data quality gates. Build URL: ${env.BUILD_URL}"
                )
            }
        }
    }
}
