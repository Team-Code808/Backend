#!/bin/bash

# 음성 녹음 기능 설정 스크립트 (Linux/Mac)
# 이 스크립트는 Google Cloud Speech-to-Text API 설정을 도와줍니다.

echo "========================================"
echo "음성 녹음 기능 설정 스크립트"
echo "========================================"
echo ""

# 1. Google Cloud 프로젝트 ID 입력
echo "[1/3] Google Cloud 프로젝트 설정"
read -p "Google Cloud 프로젝트 ID를 입력하세요 (예: my-project-111-487708): " projectId

if [ -z "$projectId" ]; then
    echo "오류: 프로젝트 ID는 필수입니다."
    exit 1
fi

# 2. 서비스 계정 키 파일 경로 입력
echo ""
echo "[2/3] Google Cloud 인증 파일 설정"
echo "Google Cloud 서비스 계정 키 JSON 파일 경로를 입력하세요."
echo "예: /home/user/google-speech-api/my-project-111-487708-32588b2dbf85.json"
read -p "인증 파일 경로: " credentialsPath

if [ -z "$credentialsPath" ]; then
    echo "경고: 인증 파일 경로가 입력되지 않았습니다."
    echo "환경 변수 GOOGLE_APPLICATION_CREDENTIALS를 수동으로 설정해야 합니다."
    useEnvVar=true
else
    # 파일 존재 확인
    if [ ! -f "$credentialsPath" ]; then
        echo "오류: 인증 파일을 찾을 수 없습니다: $credentialsPath"
        exit 1
    fi
    echo "인증 파일 확인 완료: $credentialsPath"
    useEnvVar=false
fi

# 3. application-secret.yaml 업데이트
echo ""
echo "[3/3] application-secret.yaml 설정"

secretFile="src/main/resources/application-secret.yaml"

# application-secret.yaml 파일 읽기 또는 생성
if [ -f "$secretFile" ]; then
    echo "기존 application-secret.yaml 파일을 찾았습니다. 업데이트합니다."
    existingContent=$(cat "$secretFile")
else
    echo "application-secret.yaml 파일이 없습니다. 새로 생성합니다."
    existingContent=""
fi

# Google Cloud 설정 부분 생성
googleCloudConfig="      # Google Cloud 프로젝트 ID
      project-id: $projectId"

if [ "$useEnvVar" = false ]; then
    googleCloudConfig="$googleCloudConfig
      # Google Cloud 인증 JSON 파일 경로 (절대 경로)
      credentials-path: $credentialsPath"
else
    googleCloudConfig="$googleCloudConfig
      # credentials-path가 없으면 환경 변수 GOOGLE_APPLICATION_CREDENTIALS를 사용합니다"
fi

# 기존 내용이 있는 경우
if [ -n "$existingContent" ]; then
    # app.call-record.google-cloud 섹션이 이미 있는지 확인
    if echo "$existingContent" | grep -q "app:.*call-record:.*google-cloud:"; then
        # 기존 google-cloud 섹션 업데이트 (간단한 sed 사용)
        # 주의: 복잡한 YAML 구조는 수동 편집이 더 안전할 수 있음
        echo "기존 google-cloud 설정을 찾았습니다. 수동으로 업데이트해주세요:"
        echo ""
        echo "app:"
        echo "  call-record:"
        echo "    google-cloud:"
        echo "$googleCloudConfig" | sed 's/^/      /'
        echo ""
        echo "또는 스크립트를 다시 실행하기 전에 기존 설정을 백업하세요."
    elif echo "$existingContent" | grep -q "^app:"; then
        # app 섹션은 있지만 call-record.google-cloud가 없는 경우
        if echo "$existingContent" | grep -q "call-record:"; then
            # call-record는 있지만 google-cloud가 없는 경우
            newSection="    google-cloud:
$googleCloudConfig"
            # YAML 구조 유지하며 추가 (간단한 방법)
            echo "$existingContent" > "$secretFile.tmp"
            echo "" >> "$secretFile.tmp"
            echo "$newSection" >> "$secretFile.tmp"
            mv "$secretFile.tmp" "$secretFile"
            echo "google-cloud 설정을 추가했습니다."
        else
            # call-record가 없는 경우
            newSection="  call-record:
    google-cloud:
$googleCloudConfig"
            echo "$existingContent" > "$secretFile.tmp"
            echo "" >> "$secretFile.tmp"
            echo "$newSection" >> "$secretFile.tmp"
            mv "$secretFile.tmp" "$secretFile"
            echo "call-record.google-cloud 설정을 추가했습니다."
        fi
    else
        # app 섹션이 없는 경우
        newConfig="
# Google Cloud Speech-to-Text 설정
app:
  call-record:
    google-cloud:
$googleCloudConfig
"
        echo "$existingContent" > "$secretFile.tmp"
        echo "$newConfig" >> "$secretFile.tmp"
        mv "$secretFile.tmp" "$secretFile"
        echo "app.call-record.google-cloud 설정을 추가했습니다."
    fi
else
    # 파일이 없는 경우 새로 생성
    cat > "$secretFile" << EOF
# Google Cloud Speech-to-Text 설정
app:
  call-record:
    google-cloud:
$googleCloudConfig
EOF
    echo "application-secret.yaml 파일을 생성했습니다."
fi

# 4. 환경 변수 설정 (선택사항)
if [ "$useEnvVar" = true ]; then
    echo ""
    echo "[추가] 환경 변수 설정"
    echo "현재 셸 세션에서 환경 변수를 설정하려면 다음 명령을 실행하세요:"
    echo "export GOOGLE_APPLICATION_CREDENTIALS=\"<인증파일경로>\""
    echo ""
    echo "영구적으로 설정하려면 ~/.bashrc 또는 ~/.zshrc에 추가하세요:"
    echo "echo 'export GOOGLE_APPLICATION_CREDENTIALS=\"<인증파일경로>\"' >> ~/.bashrc"
    echo ""
fi

# 5. 설정 확인
echo ""
echo "========================================"
echo "설정 완료!"
echo "========================================"
echo ""
echo "설정된 값:"
echo "  프로젝트 ID: $projectId"
if [ "$useEnvVar" = false ]; then
    echo "  인증 파일: $credentialsPath"
else
    echo "  인증 파일: 환경 변수 사용 (GOOGLE_APPLICATION_CREDENTIALS)"
fi
echo ""
echo "다음 단계:"
echo "  1. 백엔드 서버를 재시작하세요"
echo "  2. 프론트엔드에서 음성 녹음 기능을 테스트하세요"
echo ""
echo "문제가 발생하면 GOOGLE_CLOUD_STT_SETUP.md 파일을 참고하세요."

