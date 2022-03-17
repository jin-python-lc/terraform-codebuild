#!/bin/sh
job_name=(${CODEBUILD_BUILD_ID//:/ })
split_build_name=(${job_name//-/ })
project_name=${split_build_name[0]}
deploy_env=${split_build_name[1]}

echo ${job_name}
echo ${project_name}
echo ${deploy_env}

DEPLOY_ENV=deploy_env
export DEPLOY_ENV