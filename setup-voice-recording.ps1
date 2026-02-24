# 음성 녹음 기능 설정 스크립트 (Windows PowerShell)
# 이 스크립트는 Google Cloud Speech-to-Text API 설정을 도와줍니다.

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "음성 녹음 기능 설정 스크립트" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Google Cloud 프로젝트 ID 입력
Write-Host "[1/3] Google Cloud 프로젝트 설정" -ForegroundColor Yellow
$projectId = Read-Host "Google Cloud 프로젝트 ID를 입력하세요 (예: my-project-111-487708)"

if ([string]::IsNullOrWhiteSpace($projectId)) {
    Write-Host "오류: 프로젝트 ID는 필수입니다." -ForegroundColor Red
    exit 1
}

# 2. 서비스 계정 키 파일 경로 입력
Write-Host ""
Write-Host "[2/3] Google Cloud 인증 파일 설정" -ForegroundColor Yellow
Write-Host "Google Cloud 서비스 계정 키 JSON 파일 경로를 입력하세요." -ForegroundColor Gray
Write-Host "예: C:\google-speech-api\my-project-111-487708-32588b2dbf85.json" -ForegroundColor Gray
$credentialsPath = Read-Host "인증 파일 경로"

if ([string]::IsNullOrWhiteSpace($credentialsPath)) {
    Write-Host "경고: 인증 파일 경로가 입력되지 않았습니다." -ForegroundColor Yellow
    Write-Host "환경 변수 GOOGLE_APPLICATION_CREDENTIALS를 수동으로 설정해야 합니다." -ForegroundColor Yellow
    $useEnvVar = $true
} else {
    # 파일 존재 확인
    if (-not (Test-Path $credentialsPath)) {
        Write-Host "오류: 인증 파일을 찾을 수 없습니다: $credentialsPath" -ForegroundColor Red
        exit 1
    }
    Write-Host "인증 파일 확인 완료: $credentialsPath" -ForegroundColor Green
    $useEnvVar = $false
}

# 3. application-secret.yaml 업데이트
Write-Host ""
Write-Host "[3/3] application-secret.yaml 설정" -ForegroundColor Yellow

$secretFile = "src\main\resources\application-secret.yaml"

# application-secret.yaml 파일 읽기 또는 생성
$existingContent = ""
if (Test-Path $secretFile) {
    $existingContent = Get-Content $secretFile -Raw -Encoding UTF8
    Write-Host "기존 application-secret.yaml 파일을 찾았습니다. 업데이트합니다." -ForegroundColor Yellow
} else {
    Write-Host "application-secret.yaml 파일이 없습니다. 새로 생성합니다." -ForegroundColor Yellow
}

# Google Cloud 설정 부분 생성
$googleCloudConfig = @"
      # Google Cloud 프로젝트 ID
      project-id: $projectId
"@

if (-not $useEnvVar) {
    $googleCloudConfig += @"
      # Google Cloud 인증 JSON 파일 경로 (절대 경로)
      credentials-path: $credentialsPath
"@
} else {
    $googleCloudConfig += @"
      # credentials-path가 없으면 환경 변수 GOOGLE_APPLICATION_CREDENTIALS를 사용합니다
"@
}

# 기존 내용이 있는 경우
if ($existingContent) {
    # app.call-record.google-cloud 섹션이 이미 있는지 확인
    if ($existingContent -match "app:\s*\r?\n\s*call-record:\s*\r?\n\s*google-cloud:") {
        # 기존 google-cloud 섹션 업데이트
        $pattern = "(app:\s*\r?\n\s*call-record:\s*\r?\n\s*google-cloud:\s*\r?\n)(.*?)(\r?\n\s*(?:profanity:|$))"
        if ($existingContent -match $pattern) {
            $updatedContent = $existingContent -replace $pattern, "`$1$googleCloudConfig`r`n`$3"
            Set-Content -Path $secretFile -Value $updatedContent -Encoding UTF8 -NoNewline
            Write-Host "기존 google-cloud 설정을 업데이트했습니다." -ForegroundColor Green
        } else {
            # app.call-record는 있지만 google-cloud가 없는 경우
            $pattern = "(app:\s*\r?\n\s*call-record:\s*\r?\n)(\s*)(profanity:|$)"
            $newSection = "    google-cloud:`r`n$googleCloudConfig`r`n"
            $updatedContent = $existingContent -replace $pattern, "`$1$newSection`$2`$3"
            Set-Content -Path $secretFile -Value $updatedContent -Encoding UTF8 -NoNewline
            Write-Host "google-cloud 설정을 추가했습니다." -ForegroundColor Green
        }
    } elseif ($existingContent -match "app:") {
        # app 섹션은 있지만 call-record가 없는 경우
        $pattern = "(app:\s*\r?\n)(\s*)(business-card:|$)"
        $newSection = "  call-record:`r`n    google-cloud:`r`n$googleCloudConfig`r`n"
        $updatedContent = $existingContent -replace $pattern, "`$1$newSection`$2`$3"
        Set-Content -Path $secretFile -Value $updatedContent -Encoding UTF8 -NoNewline
        Write-Host "call-record.google-cloud 설정을 추가했습니다." -ForegroundColor Green
    } else {
        # app 섹션이 없는 경우
        $newConfig = @"

# Google Cloud Speech-to-Text 설정
app:
  call-record:
    google-cloud:
$googleCloudConfig
"@
        Add-Content -Path $secretFile -Value $newConfig -Encoding UTF8
        Write-Host "app.call-record.google-cloud 설정을 추가했습니다." -ForegroundColor Green
    }
} else {
    # 파일이 없는 경우 새로 생성
    $newConfig = @"
# Google Cloud Speech-to-Text 설정
app:
  call-record:
    google-cloud:
$googleCloudConfig
"@
    Set-Content -Path $secretFile -Value $newConfig -Encoding UTF8
    Write-Host "application-secret.yaml 파일을 생성했습니다." -ForegroundColor Green
}

# 4. 환경 변수 설정 (선택사항)
if ($useEnvVar) {
    Write-Host ""
    Write-Host "[추가] 환경 변수 설정" -ForegroundColor Yellow
    Write-Host "현재 PowerShell 세션에서 환경 변수를 설정하려면 다음 명령을 실행하세요:" -ForegroundColor Gray
    Write-Host "`$env:GOOGLE_APPLICATION_CREDENTIALS=`"<인증파일경로>`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "영구적으로 설정하려면 시스템 환경 변수에 추가하세요." -ForegroundColor Gray
}

# 5. 설정 확인
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "설정 완료!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "설정된 값:" -ForegroundColor Yellow
Write-Host "  프로젝트 ID: $projectId" -ForegroundColor White
if (-not $useEnvVar) {
    Write-Host "  인증 파일: $credentialsPath" -ForegroundColor White
} else {
    Write-Host "  인증 파일: 환경 변수 사용 (GOOGLE_APPLICATION_CREDENTIALS)" -ForegroundColor White
}
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "  1. 백엔드 서버를 재시작하세요" -ForegroundColor White
Write-Host "  2. 프론트엔드에서 음성 녹음 기능을 테스트하세요" -ForegroundColor White
Write-Host ""
Write-Host "문제가 발생하면 GOOGLE_CLOUD_STT_SETUP.md 파일을 참고하세요." -ForegroundColor Gray

