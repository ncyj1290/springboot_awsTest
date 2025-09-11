# AWS 초기 설정 가이드

## 1. AWS CLI 설치

### Windows
```bash
# 공식 설치 프로그램 다운로드
# https://aws.amazon.com/cli/ 에서 Windows 설치 프로그램 다운로드

# 또는 Python pip 사용
pip install awscli

# 설치 확인
aws --version
```

### macOS
```bash
# Homebrew 사용
brew install awscli

# 또는 Python pip 사용
pip install awscli
```

### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install awscli

# 또는 pip 사용
pip install awscli
```

## 2. IAM 사용자 생성 (AWS Console에서)

1. AWS Management Console 로그인
2. IAM 서비스로 이동
3. **사용자** → **사용자 추가**
4. 사용자 이름: `springboot-deployer`
5. **액세스 키 - 프로그래밍 방식 액세스** 선택
6. **기존 정책 직접 연결** 선택하고 다음 정책들 추가:
   - `AmazonECS_FullAccess`
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonRDSFullAccess`
   - `IAMFullAccess`
   - `AmazonSSMFullAccess`
   - `CloudWatchLogsFullAccess`
   - `AmazonVPCFullAccess`

⚠️ **중요**: 액세스 키와 시크릿 키를 안전하게 저장하세요!

## 3. AWS CLI 설정

```bash
# AWS CLI 설정
aws configure

# 입력할 정보:
AWS Access Key ID [None]: YOUR_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_SECRET_KEY
Default region name [None]: ap-northeast-2
Default output format [None]: json
```

## 4. 설정 확인

```bash
# 현재 설정 확인
aws configure list

# 계정 정보 확인
aws sts get-caller-identity

# 리전 확인
aws configure get region
```

## 5. 기본 VPC 확인

```bash
# VPC 목록 확인
aws ec2 describe-vpcs

# 기본 VPC ID 확인
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true"

# 서브넷 확인
aws ec2 describe-subnets
```