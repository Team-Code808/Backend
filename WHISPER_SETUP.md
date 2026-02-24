# Whisper 로컬 STT 설정 가이드 (완전 무료)

## 장점
- ✅ **완전 무료** - 인터넷 연결 불필요
- ✅ **높은 정확도** - OpenAI Whisper 모델 사용
- ✅ **오프라인 작동** - 모든 처리가 로컬에서 진행
- ✅ **데이터 보안** - 오디오 파일이 외부로 전송되지 않음

## 필수 요구사항

### 1. Python 설치
- Python 3.8 이상 필요
- [Python 다운로드](https://www.python.org/downloads/)

### 2. Whisper 설치
```bash
pip install openai-whisper
```

### 3. FFmpeg 설치 (오디오 변환용)
- **Windows**: [FFmpeg 다운로드](https://ffmpeg.org/download.html)
  - 다운로드 후 시스템 PATH에 추가
- **Mac**: `brew install ffmpeg`
- **Linux**: `sudo apt install ffmpeg`

## 설정

### application.yaml
```yaml
app:
  call-record:
    stt:
      provider: whisper-local
    whisper:
      python-command: python  # 또는 python3
      model: base  # tiny | base | small | medium | large
      temp-dir: ./temp
```

### 모델 선택 가이드
- **tiny**: 가장 빠름, 낮은 정확도 (약 1GB RAM)
- **base**: 빠름, 좋은 정확도 (약 1GB RAM) ⭐ **권장**
- **small**: 중간 속도, 높은 정확도 (약 2GB RAM)
- **medium**: 느림, 매우 높은 정확도 (약 5GB RAM)
- **large**: 가장 느림, 최고 정확도 (약 10GB RAM)

## 테스트

### Python/Whisper 설치 확인
```bash
python --version
python -m whisper --help
```

### 수동 테스트
```bash
whisper audio.wav --model base --language ko
```

## 성능

- **base 모델**: 1분 오디오 약 10-30초 처리 시간
- **small 모델**: 1분 오디오 약 30-60초 처리 시간
- **large 모델**: 1분 오디오 약 2-5분 처리 시간

## 문제 해결

### "whisper 모듈을 찾을 수 없습니다"
```bash
pip install --upgrade openai-whisper
```

### "ffmpeg를 찾을 수 없습니다"
- FFmpeg가 PATH에 추가되었는지 확인
- 재시작 후 다시 시도

### 처리 속도가 느림
- 더 작은 모델 사용 (tiny, base)
- GPU가 있다면 자동으로 사용됨 (CUDA 필요)

## 대안: AssemblyAI (무료 API)

로컬 설치가 어렵다면 AssemblyAI 무료 티어 사용:
- 월 5시간 무료
- API 키만 필요
- 설정: `provider: assemblyai`

