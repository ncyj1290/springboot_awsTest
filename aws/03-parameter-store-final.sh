#!/bin/bash

echo "=== Parameter Store 최종 설정 ==="

# RDS 인스턴스 정보 가져오기
echo "RDS 인스턴스 정보 확인 중..."

DB_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier springboot-mysql \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

DB_STATUS=$(aws rds describe-db-instances \
    --db-instance-identifier springboot-mysql \
    --query 'DBInstances[0].DBInstanceStatus' \
    --output text)

if [ "$DB_STATUS" != "available" ]; then
    echo "❌ RDS 인스턴스가 아직 준비되지 않았습니다."
    echo "현재 상태: $DB_STATUS"
    echo "다음 명령어로 상태를 확인하세요:"
    echo "aws rds describe-db-instances --db-instance-identifier springboot-mysql --query 'DBInstances[0].DBInstanceStatus'"
    exit 1
fi

echo "✅ RDS 엔드포인트: $DB_ENDPOINT"

# Parameter Store에 데이터베이스 연결 정보 저장
echo "Parameter Store에 설정 저장 중..."

DB_URL="jdbc:mysql://${DB_ENDPOINT}:3306/springdb"
DB_USERNAME="admin"
DB_PASSWORD="SpringBoot2024!"

# 파라미터 저장
aws ssm put-parameter \
    --name "/springboot/db/url" \
    --value "$DB_URL" \
    --type "String" \
    --description "SpringBoot 애플리케이션 데이터베이스 URL" \
    --overwrite

aws ssm put-parameter \
    --name "/springboot/db/username" \
    --value "$DB_USERNAME" \
    --type "String" \
    --description "SpringBoot 애플리케이션 데이터베이스 사용자명" \
    --overwrite

aws ssm put-parameter \
    --name "/springboot/db/password" \
    --value "$DB_PASSWORD" \
    --type "SecureString" \
    --description "SpringBoot 애플리케이션 데이터베이스 비밀번호" \
    --overwrite

echo "✅ Parameter Store 설정 완료"
echo ""

# 설정 확인
echo "저장된 파라미터 확인:"
echo "URL: $(aws ssm get-parameter --name /springboot/db/url --query 'Parameter.Value' --output text)"
echo "Username: $(aws ssm get-parameter --name /springboot/db/username --query 'Parameter.Value' --output text)"
echo "Password: [SecureString으로 암호화됨]"
echo ""

# 최종 배포 정보 업데이트
cat >> deployment-info.txt << EOF

=== Parameter Store 설정 완료 ===
데이터베이스 URL: $DB_URL
데이터베이스 사용자: $DB_USERNAME
RDS 엔드포인트: $DB_ENDPOINT

✅ 모든 AWS 리소스 준비 완료!

다음 단계:
1. GitHub 리포지토리 생성
2. GitHub Secrets 설정:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
3. 코드 푸시하여 자동 배포 시작
EOF

echo "🎉 모든 AWS 설정이 완료되었습니다!"
echo ""
echo "📋 deployment-info.txt 파일을 확인하여 GitHub Secrets를 설정하세요."
echo ""
echo "🚀 이제 GitHub에 코드를 푸시하면 자동으로 배포됩니다!"