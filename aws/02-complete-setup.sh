#!/bin/bash

echo "=== SpringBoot AWS 전체 설정 스크립트 ==="
echo "이 스크립트는 AWS 리소스를 순차적으로 생성합니다."
echo ""

# 현재 AWS 설정 확인
echo "1. AWS 설정 확인 중..."
aws sts get-caller-identity > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ AWS CLI가 설정되지 않았습니다. 먼저 'aws configure'를 실행하세요."
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

echo "✅ AWS 계정: $ACCOUNT_ID"
echo "✅ 리전: $REGION"
echo ""

# 1. VPC 및 보안 그룹 설정
echo "2. VPC 및 보안 그룹 설정 중..."
chmod +x 01-vpc-security-setup.sh
./01-vpc-security-setup.sh

if [ ! -f "aws-resources.txt" ]; then
    echo "❌ VPC 설정 실패"
    exit 1
fi

# 생성된 리소스 정보 로드
source aws-resources.txt

echo "✅ VPC 설정 완료"
echo ""

# 2. IAM 역할 생성
echo "3. IAM 역할 생성 중..."
chmod +x iam-setup.sh
./iam-setup.sh

echo "✅ IAM 역할 생성 완료"
echo ""

# 3. ECR 리포지토리 생성
echo "4. ECR 리포지토리 생성 중..."
aws ecr create-repository \
    --repository-name springboot-app \
    --region $REGION \
    --image-scanning-configuration scanOnPush=true > /dev/null 2>&1

ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/springboot-app"
echo "✅ ECR 리포지토리 생성 완료: $ECR_URI"
echo ""

# 4. ECS 클러스터 생성
echo "5. ECS 클러스터 생성 중..."
aws ecs create-cluster \
    --cluster-name springboot-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1 > /dev/null 2>&1

echo "✅ ECS 클러스터 생성 완료"
echo ""

# 5. CloudWatch 로그 그룹 생성
echo "6. CloudWatch 로그 그룹 생성 중..."
aws logs create-log-group \
    --log-group-name "/ecs/springboot-task" \
    --region $REGION > /dev/null 2>&1

echo "✅ CloudWatch 로그 그룹 생성 완료"
echo ""

# 6. RDS 서브넷 그룹 생성
echo "7. RDS 서브넷 그룹 생성 중..."
aws rds create-db-subnet-group \
    --db-subnet-group-name springboot-subnet-group \
    --db-subnet-group-description "Subnet group for SpringBoot RDS" \
    --subnet-ids $SUBNET1_ID $SUBNET2_ID > /dev/null 2>&1

echo "✅ RDS 서브넷 그룹 생성 완료"
echo ""

# 7. RDS 인스턴스 생성
echo "8. RDS MySQL 인스턴스 생성 중... (5-10분 소요)"
DB_PASSWORD="SpringBoot2024!"

aws rds create-db-instance \
    --db-instance-identifier springboot-mysql \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0 \
    --allocated-storage 20 \
    --db-name springdb \
    --master-username admin \
    --master-user-password $DB_PASSWORD \
    --vpc-security-group-ids $RDS_SECURITY_GROUP_ID \
    --db-subnet-group-name springboot-subnet-group \
    --backup-retention-period 7 \
    --multi-az false \
    --publicly-accessible false \
    --storage-type gp2 > /dev/null 2>&1

echo "✅ RDS 인스턴스 생성 시작 (완료까지 5-10분 소요)"
echo ""

# 8. Task Definition 파일 업데이트
echo "9. Task Definition 파일 업데이트 중..."
sed -i "s/YOUR_ACCOUNT_ID/$ACCOUNT_ID/g" ../task-definition.json

echo "✅ Task Definition 파일 업데이트 완료"
echo ""

# 9. 최종 설정 정보 생성
cat > deployment-info.txt << EOF
=== SpringBoot AWS 배포 정보 ===

AWS 계정 ID: $ACCOUNT_ID
리전: $REGION

생성된 리소스:
- VPC: $VPC_ID
- 서브넷: $SUBNET1_ID, $SUBNET2_ID  
- ECS 보안그룹: $ECS_SECURITY_GROUP_ID
- RDS 보안그룹: $RDS_SECURITY_GROUP_ID
- ECR 리포지토리: $ECR_URI
- ECS 클러스터: springboot-cluster
- RDS 인스턴스: springboot-mysql (생성 중)

다음 단계:
1. RDS 인스턴스 생성 완료 대기 (5-10분)
2. Parameter Store 설정
3. GitHub Secrets 설정
4. 코드 푸시하여 배포 시작

GitHub Secrets에 추가할 정보:
AWS_ACCESS_KEY_ID: [IAM 사용자의 액세스 키]
AWS_SECRET_ACCESS_KEY: [IAM 사용자의 시크릿 키]
EOF

echo "=== 설정 완료 ==="
echo ""
echo "📋 deployment-info.txt 파일에 모든 정보가 저장되었습니다."
echo ""
echo "🔄 다음 단계:"
echo "1. RDS 인스턴스 생성 완료까지 5-10분 대기"
echo "2. 다음 명령어로 RDS 상태 확인:"
echo "   aws rds describe-db-instances --db-instance-identifier springboot-mysql --query 'DBInstances[0].DBInstanceStatus'"
echo ""
echo "3. RDS가 'available' 상태가 되면 Parameter Store 설정:"
echo "   ./03-parameter-store-final.sh"
echo ""
echo "4. GitHub Secrets 설정 후 코드 푸시"