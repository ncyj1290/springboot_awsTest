#!/bin/bash

# IAM 역할 생성 스크립트

echo "IAM 역할 생성 중..."

# ECS Task Execution Role 신뢰 정책
cat > trust-policy-execution.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# ECS Task Role 신뢰 정책
cat > trust-policy-task.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# SSM Parameter Store 접근 정책
cat > ssm-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:ap-northeast-2:*:parameter/springboot/*"
      ]
    }
  ]
}
EOF

# 1. ECS Task Execution Role 생성
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document file://trust-policy-execution.json

# 2. ECS Task Execution Role에 기본 정책 연결
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# 3. ECS Task Execution Role에 SSM 정책 연결
aws iam put-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-name SSMParameterAccess \
    --policy-document file://ssm-policy.json

# 4. ECS Task Role 생성
aws iam create-role \
    --role-name ecsTaskRole \
    --assume-role-policy-document file://trust-policy-task.json

echo "IAM 역할 생성이 완료되었습니다."
echo ""
echo "생성된 역할:"
echo "- ecsTaskExecutionRole"
echo "- ecsTaskRole"
echo ""
echo "정리..."
rm trust-policy-execution.json trust-policy-task.json ssm-policy.json