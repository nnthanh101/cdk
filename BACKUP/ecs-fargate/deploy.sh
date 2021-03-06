#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

function _logger() {
    echo -e "$(date) ${YELLOW}[*] $@ ${NC}"
}

source ./.env
# source ./cloud9.sh

echo
echo "#########################################################"
_logger "[+] Verify the prerequisites environment"
echo "#########################################################"
echo

## DEBUG
echo "[x] Verify AWS CLI": $(aws  --version)
echo "[x] Verify git":     $(git  --version)
echo "[x] Verify jq":      $(jq   --version)
echo "[x] Verify nano":    $(nano --version)
# echo "[x] Verify Docker":  $(docker version)
# echo "[x] Verify Docker Deamon":  $(docker ps -q)
# echo "[x] Verify nvm":     $(nvm ls)
echo "[x] Verify Node.js": $(node --version)
echo "[x] Verify CDK":     $(cdk  --version)
# echo "[x] Verify Python":  $(python -V)
# echo "[x] Verify Python3": $(python3 -V)
# echo "[x] Verify kubectl":  $(kubectl version --client)

echo $AWS_ACCOUNT + $AWS_REGION + $AWS_S3_BUCKET
currentPrincipalArn=$(aws sts get-caller-identity --query Arn --output text)
## Just in case, you are using an IAM role, we will switch the identity from your STS arn to the underlying role ARN.
currentPrincipalArn=$(sed 's/\(sts\)\(.*\)\(assumed-role\)\(.*\)\(\/.*\)/iam\2role\4/' <<< $currentPrincipalArn)
echo $currentPrincipalArn


echo
echo "#########################################################"
_logger "[+] Install TypeScript node_modules"
echo "#########################################################"
echo

npm install
npm run build

# echo cdk bootstrap aws://${AWS_ACCOUNT}/${AWS_REGION} \
#     --bootstrap-bucket-name ${AWS_S3_BUCKET}     \
#     --termination-protection                     \
#     --tags Cost=${PROJECT_ID}
## export CDK_NEW_BOOTSTRAP=1
## cdk bootstrap aws://${AWS_ACCOUNT}/${AWS_REGION} --show-template -v


started_time=$(date '+%d/%m/%Y %H:%M:%S')
echo
echo "#########################################################"
_logger "[+] [START] Deploy ECS-Fargate at ${started_time}"
echo "#########################################################"
echo
 
## FIXME
# cd docker
# docker rmi -f $(docker images -a -q) && docker container rm $(docker container ls -aq)
# docker image prune -f

## FIXME
# echo
# echo "#########################################################"
# _logger "[+] 2.1. [ECR] Deploy Docker to ECR >> job4u-web"
# echo "#########################################################"
# echo
# export ECR_REPOSITORY_JOB4U_WEB=job4u-web
# sh ./deploy-docker-ecr.sh

## FIXME
# echo
# echo "#########################################################"
# _logger "[+] 2.2. [ECR]Deploy Backend - job4u-byod"
# echo "#########################################################"
# echo
# sh ./deploy-docker-job4u-byod.sh

## FIXME
# echo
# echo "#########################################################"
# _logger "[+] 2.3. [ECR]Deploy Backend - job4u-sync"
# echo "#########################################################"
# echo
# sh ./deploy-docker-job4u-sync.sh

# cd ..



## DEBUG
# rm -rf cdk.out/*.* cdk.context.json

## cdk diff $AWS_CDK_STACK
## cdk synth $AWS_CDK_STACK
## cdk deploy $AWS_CDK_STACK --require-approval never
cdk deploy --all --require-approval never  

echo
echo "#########################################################"
_logger "[+] 3. [AWS CDK] Deploy Completed"
echo "#########################################################"
echo

echo
echo "#########################################################"
_logger "[+] 4. [Code Commit] Init repository "
echo "#########################################################"
echo

## FIXME
# ./codecommit.sh

## FIXME
# echo
# echo "#########################################################"
# _logger "[+] 5. Danger!!! Cleanup"
# echo "#########################################################"
# echo

## FIXME
# echo "Cleanup ..."
# cdk destroy --all --require-approval never
# aws cloudformation delete-stack --stack-name ${PROJECT_ID}

ended_time=$(date '+%d/%m/%Y %H:%M:%S')
echo
echo "#########################################################"
echo -e "${RED} [END] ECS-Fargate at ${ended_time} - ${started_time} ${NC}"
echo "#########################################################"
echo