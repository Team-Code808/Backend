# 명함 이미지 인식 → 자동 등록 (Spring AI)

## 프로바이더 교체 (Allama/Ollama ↔ Gemini)

**설정 한 줄로 교체 가능합니다.**

| 사용할 API | 설정 |
|------------|------|
| **Gemini** (기본) | `app.business-card.ai.provider: gemini` 또는 설정 생략 |
| **Ollama(LLaMA 등)** | `app.business-card.ai.provider: ollama` |

- **현재 구현**: `Gemini` (Google GenAI) – 명함 이미지 → Vision으로 텍스트 추출 후 JSON 구조화.
- **Ollama**: `OllamaBusinessCardExtraction` 빈이 `ollama`일 때 활성화.  
  구현 완료하려면 `build.gradle`에 `spring-ai-starter-model-ollama` 추가 후,  
  동일한 `UserMessage` + 이미지 `Media` 패턴으로 Ollama 비전 모델(예: llava) 호출하면 됨.

## 필드 매핑 규칙

- 명함 이미지 → AI가 다음 JSON 필드로 추출:  
  `name`, `company`, `department`, `title`, `phone`, `mobile`, `email`, `address`, `fax`, `website`
- 추출 실패/오류 시 `BusinessCardExtractedDto.extractionError`에 메시지 저장.

## 오류 처리

- 이미지 업로드 실패 → `extractionError`로 반환.
- 등록 시: 회사 미소속, 부서 불일치, 이름 누락 등 → `IllegalArgumentException` + 400.

## 중복 처리 기준

- **같은 회사(companyId)** 내에서  
  **전화번호(phone)** 또는 **이메일(email)** 이 동일하면 **기존 연락처 업데이트**, 없으면 신규 생성.

## API 요약

- `POST /api/business-card/extract` (multipart `file`)  
  → 명함 이미지 업로드 후 추출 결과(`BusinessCardExtractedDto`) 반환.
- `POST /api/business-card/register` (JSON body: `BusinessCardRegisterRequest`)  
  → 직원/외부인/협력사 + 팀(부서) 선택하여 등록.
- `GET /api/business-card/contacts`  
  → 현재 로그인 사용자 회사의 명함 연락처 목록.

인증: `/api/business-card/**` 는 `authenticated()` 필요.
