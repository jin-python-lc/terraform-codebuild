#!/bin/sh
job_name=(${CODEBUILD_BUILD_ID//:/ })
split_build_name=(${job_name//-/ })
project_name=${split_build_name[0]}
DEPLOY_ENV=${split_build_name[1]}

echo ${job_name}
echo ${project_name}
echo ${DEPLOY_ENV}

export DEPLOY_ENV