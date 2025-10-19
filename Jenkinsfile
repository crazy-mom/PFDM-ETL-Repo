// 1. Mandatory wrapper for Scripted Pipeline
node {
    // 2. Global environment variables
    env.DB_TARGET = 'QA_SQL_SERVER_INSTANCE'
    env.DB_USER   = credentials('etl-svc-user') 

    try {
        // --- Stage 1: Checkout the Code ---
        stage('Checkout Source') {
            // REMOVED 'tool' parameter to fix warning.
            git url: 'https://github.com/crazy-mom/PFDM-ETL-Repo.git', branch: 'main'
        }

        // --- Stage 2: Execute Core ETL Process (The E and L) ---
        stage('Run ETL Job') {
            echo 'Starting ETL process: Extracting and Loading Patient Bills...'
            // CRITICAL FIX: Changed single quotes to DOUBLE QUOTES (")
            sh "python3 etl_script.py --target ${env.DB_TARGET}"
        }

        // --- Stage 3: Automated Data Quality Check (The QA Step) ---
        stage('Data Quality Validation') {
            echo 'Running automated data quality checks...'
            sh 'python3 qa_validation_script.py --check rounding'
        }

    } catch (err) {
        // Failure handling is now simplified: 
        // 1. Set the build result to FAILURE.
        // 2. Re-throw the error to stop the pipeline gracefully.
        stage('Handle Failure') {
            echo "Pipeline failed in stage: ${env.STAGE_NAME}"
        }

        currentBuild.result = 'FAILURE'
        throw err

    } finally {
        // 5. Cleanup and Final Notifications: This 'finally' block ALWAYS runs.
        
        stage('Final Cleanup') {
            // Archive test results (still runs on success or failure)
            junit 'test-results/validation-results.xml' 

            if (currentBuild.result == 'SUCCESS' || currentBuild.result == null) {
                echo 'ETL job completed and passed all quality checks.'
            } else {
                echo 'ETL job failed or quality validation failed.'
            }
        }
    }
}
