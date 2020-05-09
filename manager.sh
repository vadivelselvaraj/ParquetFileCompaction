#!/bin/bash

set -e

ACTION=$1

if [ "$ACTION" == "" ]; then
    ACTION="create-stack"
fi

##### Job Parameters #####

STACK_NAME="ParquetGlueJob"
JOB_NAME="ParquetFileCompactionGlueJob"
SOURCE_CODE_PREFIX="s3://S3_GLUE_JOB_BUCKET/ParquetFileCompaction"

#########################


if [ ${ACTION} == "create-stack" ]; then
    echo "Copying glue source code to ${SOURCE_CODE_PREFIX}.."
    aws s3 cp compact.py ${SOURCE_CODE_PREFIX}

    echo "Creating cloudformation stack, ${STACK_NAME}"
    aws cloudformation create-stack --stack-name ${STACK_NAME} --region us-west-2 --template-body "file://cloudformation.yml" \
        --parameters ParameterKey=GlueJobsSourceCodeS3Prefix,ParameterValue=${SOURCE_CODE_PREFIX} \
        --parameters ParameterKey=JobName,ParameterValue=${JOB_NAME} \
        --capabilities CAPABILITY_NAMED_IAM

elif [ ${ACTION} == "update-stack" ]; then
    echo "Updating cloudformation stack, ${STACK_NAME}"
    aws cloudformation update-stack --stack-name ${STACK_NAME} --region us-west-2 --template-body "file://cloudformation.yml" \
        --parameters ParameterKey=GlueJobsSourceCodeS3Prefix,ParameterValue=${SOURCE_CODE_PREFIX} \
        --parameters ParameterKey=JobName,ParameterValue=${JOB_NAME} \
        --capabilities CAPABILITY_NAMED_IAM

elif [ ${ACTION} == "delete-stack" ]; then
    echo "Deleting cloudformation stack, ${STACK_NAME}"
    aws cloudformation delete-stack --stack-name ${STACK_NAME}

elif [ ${ACTION} == "run-compaction" ]; then
    INPUT_PATH=$2
    OUTPUT_PATH=$3
    # Set default value of 1 if user didn't specify anything
    PARTITION_COUNT=${4:-1}

    if [[ -z $INPUT_PATH || -z $OUTPUT_PATH ]]; then
        echo "Please specify input and output S3 paths."
        exit 1
    fi

    GLUE_JOB_PARAMS='{ "--input_path": "'$INPUT_PATH'", "--output_path": "'$OUTPUT_PATH'", "--number_of_partitions": "'$PARTITION_COUNT'" }'
    printf "Running compaction job with params: %s \n\n" "$GLUE_JOB_PARAMS"
    aws glue start-job-run --job-name ${JOB_NAME} --arguments "${GLUE_JOB_PARAMS}"
fi