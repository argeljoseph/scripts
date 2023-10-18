#!/bin/bash
# Version 1.0
# Bash script to push start stop instances using AWS cli
#
# Creation Date      :  October 5, 2023
# Modification Date  :
# Developed by       :  Argel Casupanan
# Version History    :  1.0 - Initial version
#
LOG_FILE="ec2_instance_actions.`date +%d%m%Y%H%M%S`.log"

# Check for the action parameter
if [ $# -lt 2 ]; then
  echo "Usage: $0 <start|stop> <instance_file>"
  exit 1
fi

action="$1"
INSTANCE_FILE="$2"

# Check if the instance file exists
if [ ! -f "$INSTANCE_FILE" ]; then
  echo "$(date +"%Y-%m-%d %H:%M:%S") - Instance file $INSTANCE_FILE not found." >> "$LOG_FILE"
  exit 1
fi

# Function to perform instance actions (start or stop)
perform_instance_action() {
  local action="$1"
  local instance_id="$2"

  case "$action" in
    "start")
      aws ec2 start-instances --instance-ids "$instance_id" --profile "$AWS_PROFILE" >> "$LOG_FILE" 2>&1
      ;;
    "stop")
      aws ec2 stop-instances --instance-ids "$instance_id" --profile "$AWS_PROFILE" >> "$LOG_FILE" 2>&1
      ;;
    *)
      echo "$(date +"%Y-%m-%d %H:%M:%S") - Invalid action: $action" >> "$LOG_FILE"
      ;;
  esac
}

# Loop through each instance ID in the file and perform the specified action
while read -r instance_id; do
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $action instance: $instance_id" >> "$LOG_FILE"
  perform_instance_action "$action" "$instance_id"
done < "$INSTANCE_FILE"

echo "$(date +"%Y-%m-%d %H:%M:%S") - All instances $action-ed." >> "$LOG_FILE"
