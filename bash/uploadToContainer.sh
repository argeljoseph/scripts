#!/bin/bash
# Version 1.0
# Bash script to push backups to Azure Blob
#
# Creation Date      :  March 8, 2023
# Modification Date  :
# Developed by       :  Argel Casupanan
# Version History    :  1.0 - Initial version
#
# Bash Functions
# Get variables for script
getVariables () {
    requiredVariables=(SID dataBackupDir logBackupDir scriptDir stAccount blobSAS)
    source "$1"
    for var in "${requiredVariables[@]}"; do
        if ! grep -q "^${var}=" "$1"; then
            echo "`date +%T` ERROR: $var is not defined in $1."
            exit 1
        fi
    done
}

execSync () {
    echo "`date +%T` INFO: Uploading ${4} to $2." | tee -a $logFile
    ${scriptDir}/azcopy sync "${1}" "${2}${3}" 2>> $logFile
    if [ $? -eq 0 ]; then
        echo -e "`date +%T` INFO: Upload completed successfully." | tee -a $logFile
    else
        echo -e "`date +%T` ERROR: Upload failed." | tee -a $logFile
    fi
}

printUsage () {
  echo "Usage: uploadToContainer.sh <parameters.txt> <data/log> <schedule>"
}

checkParameters () {
    backupType=$(toLower "$2")
    schedule=$(toLower "$3")
    if [ -f "$1" ]; then
        if [ $backupType = "data" ] || [ $backupType = "log" ]; then
            if [ $schedule = "daily" ] || [ $schedule = "weekly" ] || [ $schedule = "monthly" ] || [ $schedule = "yearly" ]; then
                return 0
            else
                echo "`date +%T` ERROR: Invalid schedule. Valid options: daily, weekly, monthly, yearly"
                return 1
            fi
        else
            echo "`date +%T` ERROR: Invalid upload type. Use either log or data."
            return 1
        fi
    else
        echo "`date +%T` ERROR: The file $1 does not exist."
        return 1
    fi
}

createBlobURL () {
    blobURL=https://$(toLower "$stAccount").blob.core.windows.net/production/$(toLower "$2")/$(toLower "$SID")/$(toLower "$1")
    echo "$blobURL"
}

toLower () {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Main script
if [ $# -ne 3 ]; then
    printUsage
elif checkParameters "$1" "$2" "$3"; then
    getVariables $1
    # Set script logs name
    logFile=${scriptDir}/logs/uploadToBlob_${SID}_`date +%Y%m%d%H%M%S`.log
    echo "`date +%T` INFO: Setting variables from parameters file." | tee -a $logFile
    echo "`date +%T` INFO: SID is $SID." | tee -a $logFile
    echo "`date +%T` INFO: Data backups to be uploaded from $dataBackupDir." | tee -a $logFile
    echo "`date +%T` INFO: Log backups to be uploaded from $logBackupDir." | tee -a $logFile
    echo "`date +%T` INFO: All backups to be uploaded in storage account $stAccount." | tee -a $logFile
    echo "`date +%T` INFO: This will be a $2 backup upload to the $3 container of $SID." | tee -a $logFile
    echo "`date +%T` INFO: Script logs will be available at $logFile." | tee -a $logFile
    # Set variables for execution of sync URL:
    blobURL=$(createBlobURL $2 $3)
    if [ "`whoami`" != "$sapUser" ]; then
        echo -e "`date +%T` ERROR: Please run script as $sapUser." | tee -a $logFile
    else
        # Running actual uploads from this block
        if [ $2 = "data" ]; then
            execSync $dataBackupDir $blobURL $blobSAS "data backups"
        else
            execSync $dataBackupDir $blobURL $blobSAS "log backups"
        fi
    fi
else
    echo "`date +%T` ERROR: Invalid options provided."
fi