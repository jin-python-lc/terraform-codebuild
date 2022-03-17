#!/bin/sh
job_name=(${CODEBUILD_BUILD_ID//:/ })
split_build_name=(${job_name//-/ })
DEPLOY_ENV=${split_build_name[1]}
TFVARS_PATH=./config/${DEPLOY_ENV}/ap-northeast-1.tfvars
export DEPLOY_ENV
export TFVARS_PATH