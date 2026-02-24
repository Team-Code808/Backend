# Google Cloud Speech-to-Text 설정 가이드

## 1. Google Cloud 프로젝트 설정

### 1.1 Google Cloud 프로젝트 생성
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. 프로젝트 ID 확인

### 1.2 Speech-to-Text API 활성화
1. Google Cloud Console에서 "API 및 서비스" > "라이브러리" 이동
2. "Cloud Speech-to-Text API" 검색
3. "사용 설정" 클릭

### 1.3 서비스 계정 키 생성
1. "IAM 및 관리자" > "서비스 계정" 이동
2. "서비스 계정 만들기" 클릭
3. 서비스 계정 이름 입력 (예: `speech-to-text-service`)
4. 역할: "Cloud Speech-to-Text API 사용자" 선택
5. "키 만들기" > "JSON" 선택
6. 다운로드된 JSON 파일을 안전한 위치에 저장

## 2. 인증 설정 (선택 방법 중 하나)

### 방법 1: 환경 변수 사용 (권장)
```bash
# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account-key.json"

# Windows CMD
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\service-account-key.json

# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 방법 2: gcloud CLI 사용
```bash
# gcloud CLI 설치 후
gcloud auth application-default login
```

### 방법 3: application-secret.yaml에 직접 설정 (비권장)
```yaml
spring:
  call-record:
    google-cloud:
      project-id: your-project-id
      credentials-path: C:\path\to\service-account-key.json
```

## 3. application-secret.yaml 설정

```yaml
spring:
  call-record:
    google-cloud:
      # 프로젝트 ID (선택사항, 환경변수 GOOGLE_CLOUD_PROJECT로도 설정 가능)
      project-id: your-project-id
```

## 4. 빌드 및 실행

```bash
# 의존성 다운로드
./gradlew build

# 애플리케이션 실행
./gradlew bootRun
```

## 5. 테스트

통화 녹음 파일을 업로드하면 자동으로 Google Cloud Speech-to-Text API를 사용하여 음성을 텍스트로 변환합니다.

## 6. 비용

- **무료 할당량**: 월 60분 (매월 초기화)
- **유료**: 60분 초과 시 분당 $0.006 (한국어 기준)
- 자세한 내용: [Google Cloud Speech-to-Text 가격](https://cloud.google.com/speech-to-text/pricing)

## 7. 지원 오디오 형식

- WebM (Opus)
- WAV (Linear16)
- FLAC
- MP3
- OGG (Opus)

## 8. 문제 해결

### 인증 오류
- `GOOGLE_APPLICATION_CREDENTIALS` 환경 변수가 올바르게 설정되었는지 확인
- 서비스 계정 키 파일 경로가 올바른지 확인
- 서비스 계정에 "Cloud Speech-to-Text API 사용자" 역할이 부여되었는지 확인

### API 활성화 오류
- Google Cloud Console에서 Speech-to-Text API가 활성화되었는지 확인
- 프로젝트 ID가 올바른지 확인

### 의존성 오류
- `./gradlew build --refresh-dependencies` 실행
- `build.gradle`에 `com.google.cloud:google-cloud-speech:4.38.0` 의존성이 추가되었는지 확인

