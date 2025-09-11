#!/bin/bash

# AWS Systems Manager Parameter Store에 데이터베이스 연결 정보 저장
# RDS 인스턴스 생성 후 실제 엔드포인트로 변경 필요

# 변수 설정 (실제 값으로 변경 필요)
DB_ENDPOINT="springboot-mysql.xxxxxxxxx.ap-northeast-2.rds.amazonaws.com"
DB_PORT="3306"
DB_NAME="springdb"
DB_USERNAME="admin"
DB_PASSWORD="SecurePassword123!"

echo "Parameter Store에 데이터베이스 연결 정보 저장 중..."

# 데이터베이스 URL 저장
aws ssm put-parameter \
    --name "/springboot/db/url" \
    --value "jdbc:mysql://${DB_ENDPOINT}:${DB_PORT}/${DB_NAME}" \
    --type "String" \
    --description "SpringBoot 애플리케이션 데이터베이스 URL"

# 데이터베이스 사용자명 저장
aws ssm put-parameter \
    --name "/springboot/db/username" \
    --value "$DB_USERNAME" \
    --type "String" \
    --description "SpringBoot 애플리케이션 데이터베이스 사용자명"

# 데이터베이스 비밀번호 저장 (SecureString 타입)
aws ssm put-parameter \
    --name "/springboot/db/password" \
    --value "$DB_PASSWORD" \
    --type "SecureString" \
    --description "SpringBoot 애플리케이션 데이터베이스 비밀번호"

echo "Parameter Store 설정이 완료되었습니다."
echo ""
echo "저장된 파라미터 확인:"
echo "aws ssm get-parameter --name /springboot/db/url"
echo "aws ssm get-parameter --name /springboot/db/username"
echo "aws ssm get-parameter --name /springboot/db/password --with-decryption"