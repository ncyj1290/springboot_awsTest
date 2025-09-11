#!/bin/bash

# AWS ECS 클러스터 및 서비스 설정 스크립트

# 변수 설정
CLUSTER_NAME="springboot-cluster"
SERVICE_NAME="springboot-service"
TASK_DEFINITION_NAME="springboot-task"
ECR_REPOSITORY_NAME="springboot-app"
REGION="ap-northeast-2"

echo "ECS 클러스터 및 관련 리소스 생성 중..."

# 1. ECR 리포지토리 생성
echo "ECR 리포지토리 생성..."
aws ecr create-repository \
    --repository-name $ECR_REPOSITORY_NAME \
    --region $REGION \
    --image-scanning-configuration scanOnPush=true

# 2. ECS 클러스터 생성
echo "ECS 클러스터 생성..."
aws ecs create-cluster \
    --cluster-name $CLUSTER_NAME \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 3. CloudWatch 로그 그룹 생성
echo "CloudWatch 로그 그룹 생성..."
aws logs create-log-group \
    --log-group-name "/ecs/$TASK_DEFINITION_NAME" \
    --region $REGION

# 4. ECS 서비스 생성 (태스크 정의 등록 후 실행)
echo "태스크 정의 등록 및 서비스 생성은 수동으로 진행하거나 GitHub Actions을 통해 자동화됩니다."

echo ""
echo "다음 단계:"
echo "1. AWS Console에서 VPC, 서브넷, 보안 그룹 설정"
echo "2. task-definition.json에서 YOUR_ACCOUNT_ID를 실제 계정 ID로 변경"
echo "3. GitHub Secrets에 AWS 자격증명 추가:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "4. 코드를 GitHub에 푸시하여 자동 배포 실행"