#!/bin/bash

# VPC 및 보안 그룹 자동 설정 스크립트

echo "=== AWS VPC 및 보안 그룹 설정 시작 ==="

# 기본 VPC ID 가져오기
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text)

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
    echo "기본 VPC를 찾을 수 없습니다. 새로 생성합니다..."
    
    # 새 VPC 생성
    VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
    
    # VPC에 태그 추가
    aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=springboot-vpc
    
    # 인터넷 게이트웨이 생성 및 연결
    IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
    aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
    
    # 라우팅 테이블 설정
    ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[0].RouteTableId' --output text)
    aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
    
    echo "새 VPC 생성 완료: $VPC_ID"
else
    echo "기본 VPC 발견: $VPC_ID"
fi

# 가용 영역 가져오기
AZ1=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].ZoneName' --output text)
AZ2=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[1].ZoneName' --output text)

echo "사용할 가용 영역: $AZ1, $AZ2"

# 서브넷 확인 및 생성
SUBNET_COUNT=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'length(Subnets)')

if [ "$SUBNET_COUNT" -lt 2 ]; then
    echo "서브넷이 부족합니다. 새로 생성합니다..."
    
    # 퍼블릭 서브넷 생성
    SUBNET1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text)
    SUBNET2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text)
    
    # 서브넷에 태그 추가
    aws ec2 create-tags --resources $SUBNET1_ID --tags Key=Name,Value=springboot-subnet-1
    aws ec2 create-tags --resources $SUBNET2_ID --tags Key=Name,Value=springboot-subnet-2
    
    # 퍼블릭 IP 자동 할당 설정
    aws ec2 modify-subnet-attribute --subnet-id $SUBNET1_ID --map-public-ip-on-launch
    aws ec2 modify-subnet-attribute --subnet-id $SUBNET2_ID --map-public-ip-on-launch
    
    echo "서브넷 생성 완료: $SUBNET1_ID, $SUBNET2_ID"
else
    SUBNET1_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text)
    SUBNET2_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[1].SubnetId' --output text)
    echo "기존 서브넷 사용: $SUBNET1_ID, $SUBNET2_ID"
fi

# ECS용 보안 그룹 생성
echo "ECS용 보안 그룹 생성 중..."
ECS_SG_ID=$(aws ec2 create-security-group \
    --group-name springboot-ecs-sg \
    --description "Security group for SpringBoot ECS tasks" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

# ECS 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

echo "ECS 보안 그룹 생성 완료: $ECS_SG_ID"

# RDS용 보안 그룹 생성
echo "RDS용 보안 그룹 생성 중..."
RDS_SG_ID=$(aws ec2 create-security-group \
    --group-name springboot-rds-sg \
    --description "Security group for SpringBoot RDS" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)

# RDS 보안 그룹 규칙 추가 (ECS에서만 접근 가능)
aws ec2 authorize-security-group-ingress \
    --group-id $RDS_SG_ID \
    --protocol tcp \
    --port 3306 \
    --source-group $ECS_SG_ID

echo "RDS 보안 그룹 생성 완료: $RDS_SG_ID"

# 결과 정보 저장
cat > aws-resources.txt << EOF
# AWS 리소스 정보 (자동 생성됨)
VPC_ID=$VPC_ID
SUBNET1_ID=$SUBNET1_ID
SUBNET2_ID=$SUBNET2_ID
ECS_SECURITY_GROUP_ID=$ECS_SG_ID
RDS_SECURITY_GROUP_ID=$RDS_SG_ID
REGION=ap-northeast-2
EOF

echo ""
echo "=== 설정 완료 ==="
echo "VPC ID: $VPC_ID"
echo "서브넷 1: $SUBNET1_ID"
echo "서브넷 2: $SUBNET2_ID"
echo "ECS 보안 그룹: $ECS_SG_ID"
echo "RDS 보안 그룹: $RDS_SG_ID"
echo ""
echo "aws-resources.txt 파일에 정보가 저장되었습니다."