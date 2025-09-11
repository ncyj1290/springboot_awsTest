# SpringBoot AWS 배포 가이드

이 프로젝트는 Spring Boot 애플리케이션을 AWS ECS Fargate에 자동 배포하는 구성을 포함합니다.

## 📋 사전 요구사항

- AWS CLI 설치 및 설정
- Docker 설치
- GitHub 계정
- AWS 계정

## 🏗️ 아키텍처

- **컨테이너**: Docker + Spring Boot
- **오케스트레이션**: AWS ECS Fargate
- **데이터베이스**: AWS RDS MySQL
- **CI/CD**: GitHub Actions
- **설정 관리**: AWS Systems Manager Parameter Store

## 🚀 배포 단계

### 1. AWS 리소스 설정

```bash
# IAM 역할 생성
cd aws
chmod +x iam-setup.sh
./iam-setup.sh

# RDS MySQL 인스턴스 생성
chmod +x rds-setup.sh
./rds-setup.sh

# ECS 클러스터 생성
chmod +x ecs-setup.sh
./ecs-setup.sh

# Parameter Store 설정
chmod +x parameter-store-setup.sh
./parameter-store-setup.sh
```

### 2. 설정 파일 수정

1. `task-definition.json`에서 `YOUR_ACCOUNT_ID`를 실제 AWS 계정 ID로 변경
2. `aws/rds-setup.sh`에서 서브넷 ID와 보안 그룹 ID 설정
3. `aws/parameter-store-setup.sh`에서 실제 RDS 엔드포인트로 변경

### 3. GitHub Secrets 설정

GitHub 리포지토리 Settings → Secrets and variables → Actions에서 다음 추가:

```
AWS_ACCESS_KEY_ID: <AWS 액세스 키>
AWS_SECRET_ACCESS_KEY: <AWS 시크릿 키>
```

### 4. 로컬 테스트

```bash
# Docker로 로컬 테스트
docker-compose up -d

# 애플리케이션 확인
curl http://localhost:8080

# 컨테이너 정리
docker-compose down
```

### 5. 자동 배포

코드를 main 브랜치에 푸시하면 GitHub Actions가 자동으로:
1. 테스트 실행
2. Docker 이미지 빌드
3. ECR에 푸시
4. ECS 서비스 업데이트

## 📁 파일 구조

```
├── Dockerfile                          # 컨테이너 이미지 빌드
├── docker-compose.yml                  # 로컬 개발환경
├── .dockerignore                       # Docker 빌드 제외 파일
├── task-definition.json                # ECS 태스크 정의
├── .github/workflows/deploy.yml        # CI/CD 파이프라인
├── aws/
│   ├── ecs-setup.sh                    # ECS 클러스터 설정
│   ├── rds-setup.sh                    # RDS 인스턴스 생성
│   ├── parameter-store-setup.sh        # Parameter Store 설정
│   ├── iam-setup.sh                    # IAM 역할 생성
│   └── iam-roles.json                  # IAM 역할 정의
└── src/main/resources/
    ├── application.properties          # 기본 설정
    ├── application-docker.properties   # Docker 환경 설정
    └── application-aws.properties      # AWS 환경 설정
```

## 🔧 주요 설정

### Environment Profiles
- `default`: 로컬 개발 (H2/MySQL localhost)
- `docker`: Docker Compose 환경
- `aws`: AWS 프로덕션 환경

### 보안
- RDS는 private 서브넷에 배치
- Parameter Store로 민감한 정보 관리
- 컨테이너는 비루트 사용자로 실행

## 📊 모니터링

- ECS 서비스 상태: AWS Console → ECS
- 애플리케이션 로그: CloudWatch Logs
- 헬스 체크: `/actuator/health`

## 🛠️ 문제 해결

### 일반적인 문제
1. **빌드 실패**: Gradle 권한 확인 (`chmod +x gradlew`)
2. **데이터베이스 연결 실패**: RDS 보안 그룹 및 Parameter Store 확인
3. **ECR 푸시 실패**: AWS 자격증명 및 권한 확인

### 유용한 명령어
```bash
# ECS 서비스 상태 확인
aws ecs describe-services --cluster springboot-cluster --services springboot-service

# 로그 확인
aws logs get-log-events --log-group-name /ecs/springboot-task --log-stream-name [STREAM_NAME]

# Parameter Store 확인
aws ssm get-parameter --name /springboot/db/url
```