# 프론트엔드 오디오만 녹음 가이드

## 문제
현재 `video/webm` 형식으로 녹음되어 AssemblyAI가 처리하지 못함

## 해결
프론트엔드에서 오디오만 녹음하도록 변경

## 코드 예시

### React/TypeScript 예시

```typescript
// 통화 녹음 컴포넌트
import { useState, useRef } from 'react';

function CallRecording() {
  const [isRecording, setIsRecording] = useState(false);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);

  // 오디오만 녹음 시작
  const startRecording = async () => {
    try {
      // ✅ 중요: audio만 요청 (video 제외)
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: true,   // 오디오만
        video: false   // 비디오 제외
      });

      // MediaRecorder 옵션: 오디오만
      const options = {
        mimeType: 'audio/webm',  // audio/webm으로 명시
        audioBitsPerSecond: 128000
      };

      const mediaRecorder = new MediaRecorder(stream, options);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

      mediaRecorder.onstop = async () => {
        const audioBlob = new Blob(audioChunksRef.current, { 
          type: 'audio/webm'  // ✅ audio/webm으로 명시
        });
        
        // 서버로 업로드
        await uploadRecording(audioBlob);
        
        // 스트림 정리
        stream.getTracks().forEach(track => track.stop());
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error('녹음 시작 실패:', error);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
    }
  };

  const uploadRecording = async (audioBlob: Blob) => {
    const formData = new FormData();
    formData.append('file', audioBlob, 'recording.webm');
    formData.append('customerPhone', '010-1234-5678');
    formData.append('callStartedAt', new Date().toISOString());
    formData.append('callEndedAt', new Date().toISOString());

    try {
      const response = await fetch('/api/call-records', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        },
        body: formData
      });
      // ...
    } catch (error) {
      console.error('업로드 실패:', error);
    }
  };

  return (
    <div>
      <button onClick={isRecording ? stopRecording : startRecording}>
        {isRecording ? '녹음 중지' : '녹음 시작'}
      </button>
    </div>
  );
}
```

### JavaScript (Vanilla) 예시

```javascript
let mediaRecorder;
let audioChunks = [];

async function startRecording() {
  try {
    // ✅ 중요: audio만 요청
    const stream = await navigator.mediaDevices.getUserMedia({
      audio: true,   // 오디오만
      video: false   // 비디오 제외
    });

    // MediaRecorder 옵션: 오디오만
    const options = {
      mimeType: 'audio/webm',  // audio/webm으로 명시
      audioBitsPerSecond: 128000
    };

    mediaRecorder = new MediaRecorder(stream, options);
    audioChunks = [];

    mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        audioChunks.push(event.data);
      }
    };

    mediaRecorder.onstop = async () => {
      const audioBlob = new Blob(audioChunks, { 
        type: 'audio/webm'  // ✅ audio/webm으로 명시
      });
      
      // 서버로 업로드
      await uploadRecording(audioBlob);
      
      // 스트림 정리
      stream.getTracks().forEach(track => track.stop());
    };

    mediaRecorder.start();
  } catch (error) {
    console.error('녹음 시작 실패:', error);
  }
}

function stopRecording() {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop();
  }
}

async function uploadRecording(audioBlob) {
  const formData = new FormData();
  formData.append('file', audioBlob, 'recording.webm');
  formData.append('customerPhone', '010-1234-5678');
  formData.append('callStartedAt', new Date().toISOString());
  formData.append('callEndedAt', new Date().toISOString());

  try {
    const response = await fetch('/api/call-records', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: formData
    });
    // ...
  } catch (error) {
    console.error('업로드 실패:', error);
  }
}
```

### Vue.js 예시

```vue
<template>
  <div>
    <button @click="isRecording ? stopRecording() : startRecording()">
      {{ isRecording ? '녹음 중지' : '녹음 시작' }}
    </button>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const isRecording = ref(false);
let mediaRecorder = null;
let audioChunks = [];

const startRecording = async () => {
  try {
    // ✅ 중요: audio만 요청
    const stream = await navigator.mediaDevices.getUserMedia({
      audio: true,   // 오디오만
      video: false   // 비디오 제외
    });

    const options = {
      mimeType: 'audio/webm',
      audioBitsPerSecond: 128000
    };

    mediaRecorder = new MediaRecorder(stream, options);
    audioChunks = [];

    mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        audioChunks.push(event.data);
      }
    };

    mediaRecorder.onstop = async () => {
      const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
      await uploadRecording(audioBlob);
      stream.getTracks().forEach(track => track.stop());
    };

    mediaRecorder.start();
    isRecording.value = true;
  } catch (error) {
    console.error('녹음 시작 실패:', error);
  }
};

const stopRecording = () => {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop();
    isRecording.value = false;
  }
};

const uploadRecording = async (audioBlob) => {
  const formData = new FormData();
  formData.append('file', audioBlob, 'recording.webm');
  // ... 나머지 필드 추가
  
  // API 호출
};
</script>
```

## 핵심 변경 사항

### 1. getUserMedia 옵션
```javascript
// ❌ 기존 (비디오 포함)
const stream = await navigator.mediaDevices.getUserMedia({
  audio: true,
  video: true  // 이게 문제!
});

// ✅ 수정 (오디오만)
const stream = await navigator.mediaDevices.getUserMedia({
  audio: true,
  video: false  // 비디오 제외
});
```

### 2. MediaRecorder MIME 타입
```javascript
// ✅ audio/webm으로 명시
const options = {
  mimeType: 'audio/webm',  // video/webm이 아닌 audio/webm
  audioBitsPerSecond: 128000
};
```

### 3. Blob 타입 명시
```javascript
// ✅ audio/webm으로 명시
const audioBlob = new Blob(audioChunks, { 
  type: 'audio/webm'  // video/webm이 아닌 audio/webm
});
```

## 확인 방법

업로드 전에 파일 타입 확인:
```javascript
console.log('파일 타입:', audioBlob.type);  // "audio/webm"이어야 함
```

## 추가 팁

### WAV 형식 사용 (더 호환성 좋음)
```javascript
const options = {
  mimeType: 'audio/wav',  // 또는 'audio/webm'
  audioBitsPerSecond: 128000
};
```

### 브라우저 호환성 확인
```javascript
if (MediaRecorder.isTypeSupported('audio/webm')) {
  // audio/webm 지원
} else if (MediaRecorder.isTypeSupported('audio/wav')) {
  // audio/wav 사용
}
```

