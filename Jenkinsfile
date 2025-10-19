pipeline {
    // 1. Define where the pipeline runs (agent is mandatory in Declarative syntax)
    agent any 

    // 2. Global environment variables (e.g., database connection details)
    environment {
        DB_TARGET = 'QA_SQL_SERVER_INSTANCE'
        DB_USER   = credentials('etl-svc-user') // Stored Jenkins credential ID
    }

    // 3. Define the stages of the pipeline
    stages {
        // --- Stage 1: Checkout the Code ---
        // Keeping this separate for clarity on where the pipeline obtains code.
        stage('Checkout Source') {
            steps {
                // Ensure the repository is checked out. 
                git url: 'https://github.com/crazy-mom/PFDM-ETL-Repo.git', branch: 'main'
            }
        }

        // --- Stage 2: Execute Core ETL Process (The E and L) ---
        stage('Run ETL Job') {
            steps {
                echo 'Starting ETL process: Extracting and Loading Patient Bills...'
                // Use the environment variable DB_TARGET
                sh 'python3 etl_script.py --target ${DB_TARGET}'
            }
            // Immediate notification on failure for the core job
            post {
                failure {
                    emailext (
                        to: 'gnayyar06@gmail.com',
                        subject: "CRITICAL FAILURE: PFDM ETL Load",
                        body: "The core ETL job failed. Check Jenkins console log for details at ${env.BUILD_URL}"
                    )
                }
            }
        }

        // --- Stage 3: Automated Data Quality Check (The QA Step) ---
        stage('Data Quality Validation') {
            steps {
                echo 'Running automated data quality checks...'
                // Executes a script that should return a non-zero exit code if the data quality fails.
                sh 'python3 qa_validation_script.py --check rounding'
            }
        }

        // --- Stage 4: Final Notifications ---
        stage('Final Notifications') {
            steps {
                echo 'Archiving test results and sending final status notification.'
            }
            // No need for a script block here; post-build logic is better in the post section.
        }
    }

    // 4. Post-build actions for the entire pipeline
    post {
        // Always run, typically for cleanup or archiving results
        always {
            // Archive test results from the Data Quality stage
            junit 'test-results/validation-results.xml' 
        }
        
        // Final email notification on failure (triggered by Stage 3 failure)
        failure {
            emailext (
                to: 'qa-team@company.com', 
                subject: "DQ ALERT: PFDM Rounding Error Detected (Build ${env.BUILD_NUMBER})", 
                body: "Data Quality stage FAILED. Investigate the DW_Bills table immediately. Build URL: ${env.BUILD_URL}"
            )
        }
        
        // Final email notification on success
        success {
            emailext (
                to: 'data-ops@company.com', 
                subject: "SUCCESS: PFDM Daily Load Complete (Build ${env.BUILD_NUMBER})", 
                body: "The ETL job completed and passed all data quality gates. Build URL: ${env.BUILD_URL}"
            )
        }
    }
}
