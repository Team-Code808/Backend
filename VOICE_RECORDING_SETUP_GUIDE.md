# 음성 녹음 기능 설정 가이드

이 가이드는 팀원들이 음성 녹음 기능을 사용하기 위해 필요한 설정을 안내합니다.

## 📋 필수 준비사항

1. **Google Cloud 계정** (무료 체험 계정 가능)
2. **Google Cloud 프로젝트** 생성
3. **Speech-to-Text API 활성화**
4. **서비스 계정 키 파일** (JSON)

---

## 🚀 빠른 설정 (자동 스크립트 사용)

### Windows 사용자

1. PowerShell을 관리자 권한으로 실행
2. 백엔드 프로젝트 디렉토리로 이동
   ```powershell
   cd "파이널 백엔드"
   ```
3. 설정 스크립트 실행
   ```powershell
   .\setup-voice-recording.ps1
   ```
4. 스크립트가 안내하는 대로 입력:
   - Google Cloud 프로젝트 ID
   - 서비스 계정 키 파일 경로

### Linux/Mac 사용자

1. 터미널에서 백엔드 프로젝트 디렉토리로 이동
   ```bash
   cd "파이널 백엔드"
   ```
2. 스크립트에 실행 권한 부여
   ```bash
   chmod +x setup-voice-recording.sh
   ```
3. 설정 스크립트 실행
   ```bash
   ./setup-voice-recording.sh
   ```
4. 스크립트가 안내하는 대로 입력:
   - Google Cloud 프로젝트 ID
   - 서비스 계정 키 파일 경로

---

## 📝 수동 설정 방법

### 1단계: Google Cloud 프로젝트 설정

#### 1.1 프로젝트 생성
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 상단의 프로젝트 선택 메뉴 클릭
3. "새 프로젝트" 클릭
4. 프로젝트 이름 입력 (예: `calmdesk-voice`)
5. "만들기" 클릭
6. **프로젝트 ID를 기록해두세요** (예: `my-project-111-487708`)

#### 1.2 Speech-to-Text API 활성화
1. Google Cloud Console에서 "API 및 서비스" > "라이브러리" 이동
2. 검색창에 "Cloud Speech-to-Text API" 입력
3. "Cloud Speech-to-Text API" 선택
4. "사용 설정" 버튼 클릭

#### 1.3 서비스 계정 키 생성
1. "IAM 및 관리자" > "서비스 계정" 이동
2. "서비스 계정 만들기" 클릭
3. 서비스 계정 정보 입력:
   - **서비스 계정 이름**: `speech-to-text-service` (또는 원하는 이름)
   - **서비스 계정 ID**: 자동 생성됨
   - "만들기 및 계속" 클릭
4. 역할 부여:
   - "역할 선택" 드롭다운에서 "Cloud Speech-to-Text API 사용자" 선택
   - "계속" 클릭
5. "완료" 클릭
6. 생성된 서비스 계정 클릭
7. "키" 탭으로 이동
8. "키 추가" > "새 키 만들기" 클릭
9. 키 유형: **JSON** 선택
10. "만들기" 클릭
11. **JSON 파일이 자동으로 다운로드됩니다** → 안전한 위치에 저장
    - 예: `C:\google-speech-api\my-project-111-487708-32588b2dbf85.json`
    - 예: `/home/user/google-speech-api/my-project-111-487708-32588b2dbf85.json`

### 2단계: 백엔드 설정

#### 2.1 application-secret.yaml 파일 설정

`파이널 백엔드/src/main/resources/application-secret.yaml` 파일을 열고 다음 설정을 추가합니다:

```yaml
# 기존 설정들...

# Google Cloud Speech-to-Text 설정
app:
  call-record:
    google-cloud:
      # Google Cloud 프로젝트 ID
      project-id: your-project-id-here
      # Google Cloud 인증 JSON 파일 경로 (절대 경로)
      credentials-path: C:\path\to\your-service-account-key.json
```

**Windows 예시:**
```yaml
app:
  call-record:
    google-cloud:
      project-id: my-project-111-487708
      credentials-path: C:\google-speech-api\my-project-111-487708-32588b2dbf85.json
```

**Linux/Mac 예시:**
```yaml
app:
  call-record:
    google-cloud:
      project-id: my-project-111-487708
      credentials-path: /home/user/google-speech-api/my-project-111-487708-32588b2dbf85.json
```

#### 2.2 환경 변수 사용 (선택사항)

`credentials-path`를 설정하지 않으면 환경 변수를 사용할 수 있습니다.

**Windows PowerShell:**
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account-key.json"
```

**Windows CMD:**
```cmd
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\service-account-key.json
```

**Linux/Mac:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

영구적으로 설정하려면:
- **Windows**: 시스템 환경 변수에 추가
- **Linux/Mac**: `~/.bashrc` 또는 `~/.zshrc`에 추가
  ```bash
  echo 'export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"' >> ~/.bashrc
  source ~/.bashrc
  ```

### 3단계: 프론트엔드 설정

`파이널 프론트/src/Config.jsx` 파일을 확인합니다:

```javascript
export const API_URL = "http://localhost:8080";
```

백엔드 서버가 다른 포트나 주소에서 실행되는 경우 이 값을 수정하세요.

### 4단계: 백엔드 서버 재시작

설정을 변경한 후 백엔드 서버를 재시작해야 합니다:

```bash
# Windows
.\gradlew bootRun

# Linux/Mac
./gradlew bootRun
```

---

## ✅ 설정 확인

설정이 올바르게 되었는지 확인하는 방법:

1. 백엔드 서버를 시작합니다
2. 로그에서 다음 메시지를 확인합니다:
   ```
   Google Cloud 인증: application-secret.yaml의 credentials-path 사용 - C:\...
   Google Cloud 인증: SpeechClient 생성 완료
   ```
3. 프론트엔드에서 음성 녹음을 테스트합니다:
   - `/app/call` 페이지로 이동
   - "녹음 시작" 버튼 클릭
   - 마이크 권한 허용
   - 음성 녹음 후 업로드
   - 통화 기록에서 STT 결과 확인

---

## 🔧 문제 해결

### 인증 오류
- **증상**: `Google Cloud 인증 JSON 파일을 찾을 수 없습니다`
- **해결**: 
  - `credentials-path`가 올바른지 확인
  - 파일 경로에 한글이나 특수문자가 없는지 확인
  - 절대 경로를 사용하는 것을 권장

### API 활성화 오류
- **증상**: `API not enabled` 또는 `Permission denied`
- **해결**:
  - Google Cloud Console에서 Speech-to-Text API가 활성화되었는지 확인
  - 서비스 계정에 "Cloud Speech-to-Text API 사용자" 역할이 부여되었는지 확인

### 프로젝트 ID 오류
- **증상**: `Project not found`
- **해결**:
  - `project-id`가 올바른지 확인
  - Google Cloud Console에서 프로젝트 ID 확인

### 환경 변수 설정이 안 되는 경우
- Windows: PowerShell을 관리자 권한으로 실행
- Linux/Mac: `~/.bashrc` 또는 `~/.zshrc` 파일을 수정한 후 `source` 명령 실행

---

## 💰 비용 정보

- **무료 할당량**: 월 60분 (매월 초기화)
- **유료**: 60분 초과 시 분당 $0.006 (한국어 기준)
- 자세한 내용: [Google Cloud Speech-to-Text 가격](https://cloud.google.com/speech-to-text/pricing)

---

## 📚 추가 참고 자료

- [GOOGLE_CLOUD_STT_SETUP.md](./GOOGLE_CLOUD_STT_SETUP.md) - 상세한 설정 가이드
- [Google Cloud Speech-to-Text 문서](https://cloud.google.com/speech-to-text/docs)

---

## ⚠️ 보안 주의사항

1. **서비스 계정 키 파일은 절대 Git에 커밋하지 마세요!**
2. `application-secret.yaml` 파일은 `.gitignore`에 포함되어 있어야 합니다
3. 서비스 계정 키 파일은 안전한 위치에 보관하세요
4. 팀원들과 키 파일을 공유할 때는 안전한 방법을 사용하세요 (예: 암호화된 파일 공유)

---

## 🆘 도움이 필요하신가요?

설정 중 문제가 발생하면:
1. 이 가이드의 "문제 해결" 섹션을 확인하세요
2. 백엔드 로그를 확인하세요
3. 팀 리더에게 문의하세요

