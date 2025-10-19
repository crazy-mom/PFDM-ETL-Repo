// Global environment variables (e.g., database connection details)
environment {
    DB_TARGET = 'QA_SQL_SERVER_INSTANCE'
    DB_USER   = credentials('etl-svc-user') // Stored Jenkins credential ID
}

stages {
    // --- Stage 1: Checkout the Code ---
    stage('Checkout Code') {
        steps {
            // Assuming the ETL code (e.g., Python scripts, SQL files) is in a Git repository
            git url: 'https://github.com/crazy-mom/PFDM-ETL-Repo.git', branch: 'main'
        }
    }

    // --- Stage 2: Execute Core ETL Process ---
    // This is the step that actually pulls data from Source and loads it to Target (the E and L).
    stage('Run ETL Job') {
        steps {
            echo 'Starting ETL process: Extracting and Loading Patient Bills...'
            // Command to execute the main ETL script (e.g., a Python script)
            sh 'python3 etl_script.py --target ${DB_TARGET}'
        }
        // Optional: Use a post-failure condition to notify the developer immediately
        post {
            failure {
                // Send notification if the main ETL script fails due to a connection or syntax error
                mail to: 'gnayyar06@gmail.com',
                     subject: "CRITICAL FAILURE: PFDM ETL Load",
                     body: "The core ETL job failed. Check Jenkins console log for details."
            }
        }
    }

    // --- Stage 3: Automated Data Quality Check (The QA Step) ---
    // This is where we run our Step 12 logic to automatically catch the rounding bug.
    stage('Data Quality Validation') {
        steps {
            echo 'Running automated data quality checks...'
            // Execute a separate Python script that runs the critical T-SQL validation query
            // from the previous steps (looking for ROUND != LOADED).
            sh 'python3 qa_validation_script.py --check rounding'
        }
    }

    // --- Stage 4: Final Reporting and Notifications ---
    stage('Final Notifications') {
        steps {
            script {
                // Use the current build status for the subject line
                if (currentBuild.currentResult == 'SUCCESS') {
                    echo 'ETL job and data quality check successful.'
                } else {
                    // This block runs if Stage 3 (Quality Validation) failed
                    echo 'Data Quality Validation FAILED. Alerting QA team.'
                }
            }
        }
        // Send final email based on the overall build status
        post {
            always {
                junit 'test-results/validation-results.xml' // Archive test results
            }
            failure {
                mail to: 'qa-team@company.com', subject: "DQ ALERT: PFDM Rounding Error Detected", body: "Data Quality stage failed. Investigate the DW_Bills table immediately."
            }
            success {
                mail to: 'data-ops@company.com', subject: "SUCCESS: PFDM Daily Load Complete", body: "The ETL job completed and passed all data quality gates."
            }
        }
    }
}


}
