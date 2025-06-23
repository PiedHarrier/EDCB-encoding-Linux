#!/bin/bash

_EDCBX_NORMAL_

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
HOME_DIR="$HOME"
LOG_FILE="$HOME_DIR/encorde.log"
WORKDIR="/home/User/JoinLogoScpTrialSetLinux"

# --- Get Environment Variables ---
if [[ -z "$FileName" ]]; then
    echo "Error: Environment variable 'FileName' is not set or empty." >&2
    exit 1
fi

TS_FILENAME="${FileName}.ts"
INPUT_DIR="${FileDir:-/var/local/edcb/HttpPublic/video}"
INPUT_FILE="$INPUT_DIR/$TS_FILENAME"

# --- Helper Functions ---
log_message() {
    # The 'tee -a' command appends the message to the log file
    # while also printing it to the console.
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# --- Main Script Body ---
log_message "Script started. Processing file: $INPUT_FILE"

# 1. Validation
if [[ ! -f "$INPUT_FILE" ]]; then
    log_message "Error: Input file not found - $INPUT_FILE"
    exit 1
fi

if [[ ! -d "$WORKDIR" ]]; then
    log_message "Error: Working directory not found - $WORKDIR"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_message "Error: 'docker-compose' command not found."
    exit 1
fi

# 2. Execution
log_message "Executing docker-compose command..."

# We append all output from the subsequent commands directly to the log file
exec &>> "$LOG_FILE"

# Change to the working directory and run the command.
# Because of 'set -e', the script will automatically exit if this command fails.
cd "$WORKDIR"
docker-compose run --rm -v "$INPUT_DIR":/ts join_logo_scp_trial "/ts/$TS_FILENAME" -e -t cutcm -o " -c:v libx264 -vf bwdif=1 -preset medium -crf 23 -aspect 16:9" -r

# 3. Log Success
# This line will only be reached if the docker-compose command succeeds.
log_message "Encoding completed successfully for $INPUT_FILE"
log_message "Script finished."

exit 0
