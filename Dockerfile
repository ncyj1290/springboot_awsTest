# OpenJDK 21을 기반으로 하는 이미지 사용
FROM openjdk:21-jdk-slim

# 작업 디렉토리 설정
WORKDIR /app

# 애플리케이션을 실행할 사용자 생성 (보안상 권장)
RUN addgroup --system spring && adduser --system --ingroup spring spring

# 빌드된 JAR 파일을 컨테이너로 복사
COPY build/libs/*.jar app.jar

# 파일 소유권 변경
RUN chown spring:spring app.jar

# 애플리케이션 실행 사용자 변경
USER spring:spring

# 포트 8080 노출
EXPOSE 8080

# JVM 메모리 옵션 추가 (선택적)
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 애플리케이션 실행
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]