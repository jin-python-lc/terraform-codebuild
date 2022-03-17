#!/bin/sh

echo ${CODEBUILD_BUILD_ID}

job_name=(${CODEBUILD_BUILD_ID//:/ })
project_name=${(${job_name//-/ })[0]}
deploy_env=${(${job_name//-/ })[1]}