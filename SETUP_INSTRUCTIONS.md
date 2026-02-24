# 실행 전 필수 설치 가이드

## 1단계: Python 설치

### Windows
1. [Python 공식 사이트](https://www.python.org/downloads/) 접속
2. "Download Python 3.x.x" 클릭 (최신 버전)
3. 다운로드한 파일 실행
4. **중요**: "Add Python to PATH" 체크박스 반드시 선택!
5. "Install Now" 클릭
6. 설치 완료 후 터미널 재시작

### 설치 확인
```powershell
python --version
# Python 3.x.x 가 나와야 함
```

## 2단계: Whisper 설치

Python 설치 후:
```powershell
pip install openai-whisper
```

### 설치 확인
```powershell
python -m whisper --help
```

## 3단계: FFmpeg 설치

### 방법 1: Chocolatey 사용 (권장)
```powershell
# 관리자 권한 PowerShell에서
choco install ffmpeg
```

### 방법 2: 수동 설치
1. [FFmpeg 다운로드](https://www.gyan.dev/ffmpeg/builds/)
2. "ffmpeg-release-essentials.zip" 다운로드
3. 압축 해제 (예: `C:\ffmpeg`)
4. 시스템 환경 변수 PATH에 `C:\ffmpeg\bin` 추가
5. 터미널 재시작

### 설치 확인
```powershell
ffmpeg -version
```

## 4단계: 애플리케이션 실행

모든 설치가 완료되면:
```powershell
cd "C:\Users\kimju\Desktop\파이널 백엔드"
.\gradlew.bat bootRun
```

## 빠른 설치 스크립트 (관리자 권한 필요)

```powershell
# Chocolatey 설치 (처음 한 번만)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Python, FFmpeg 설치
choco install python ffmpeg -y

# Whisper 설치
pip install openai-whisper
```

## 문제 해결

### "python을 찾을 수 없습니다"
- Python 설치 시 "Add Python to PATH"를 체크했는지 확인
- 터미널 재시작
- 환경 변수 PATH에 Python이 추가되었는지 확인

### "pip를 찾을 수 없습니다"
- Python 재설치 (PATH 체크 필수)
- 또는 `python -m pip install openai-whisper` 사용

### "ffmpeg를 찾을 수 없습니다"
- FFmpeg 설치 후 PATH에 추가했는지 확인
- 터미널 재시작

