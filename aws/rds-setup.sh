#!/bin/bash

# AWS RDS MySQL 인스턴스 생성 스크립트
# 사용 전 AWS CLI 설정 및 적절한 권한 필요

# 변수 설정
DB_INSTANCE_IDENTIFIER="springboot-mysql"
DB_ENGINE="mysql"
DB_ENGINE_VERSION="8.0"
DB_INSTANCE_CLASS="db.t3.micro"
ALLOCATED_STORAGE=20
DB_NAME="springdb"
MASTER_USERNAME="admin"
MASTER_PASSWORD="SecurePassword123!"  # 실제 사용 시 변경 필요
VPC_SECURITY_GROUP_IDS="sg-xxxxxxxxx"  # 실제 보안 그룹 ID로 변경
SUBNET_GROUP_NAME="springboot-subnet-group"

echo "RDS MySQL 인스턴스 생성 중..."

# DB 서브넷 그룹 생성
aws rds create-db-subnet-group \
    --db-subnet-group-name $SUBNET_GROUP_NAME \
    --db-subnet-group-description "Subnet group for SpringBoot RDS" \
    --subnet-ids subnet-xxxxxxxxx subnet-yyyyyyyyy \
    --tags Key=Name,Value=springboot-subnet-group

# RDS 인스턴스 생성
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
    --db-instance-class $DB_INSTANCE_CLASS \
    --engine $DB_ENGINE \
    --engine-version $DB_ENGINE_VERSION \
    --allocated-storage $ALLOCATED_STORAGE \
    --db-name $DB_NAME \
    --master-username $MASTER_USERNAME \
    --master-user-password $MASTER_PASSWORD \
    --vpc-security-group-ids $VPC_SECURITY_GROUP_IDS \
    --db-subnet-group-name $SUBNET_GROUP_NAME \
    --backup-retention-period 7 \
    --multi-az false \
    --publicly-accessible false \
    --storage-type gp2 \
    --enable-performance-insights \
    --tags Key=Name,Value=springboot-mysql Key=Environment,Value=production

echo "RDS 인스턴스 생성 명령을 실행했습니다."
echo "생성 완료까지 약 10-15분 소요됩니다."
echo ""
echo "생성 상태 확인:"
echo "aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER"