// com.code808.calmdesk.domain.Notification.service 패키지 등에 생성하세요.
package com.code808.calmdesk.domain.Notification;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
public class SseEmitters {

    // 연결된 클라이언트들을 보관하는 저장소 (userId, emitter)
    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();

    // 연결 추가
    public SseEmitter add(String userId, SseEmitter emitter) {
        this.emitters.put(userId, emitter);
        log.info("new emitter added for user: {}. current size: {}", userId, emitters.size());

        emitter.onCompletion(() -> {
            log.info("onCompletion callback for user: {}", userId);
            this.emitters.remove(userId);
        });
        emitter.onTimeout(() -> {
            log.info("onTimeout callback for user: {}", userId);
            emitter.complete();
        });

        return emitter;
    }

    // 알림 전송
    public void sendToClient(String userId, Object data) {
        SseEmitter emitter = emitters.get(userId);
        if (emitter != null) {
            try {
                // "notification"이라는 이름의 이벤트로 데이터를 보냄
                emitter.send(SseEmitter.event()
                        .name("notification")
                        .data(data));
            } catch (IOException e) {
                log.error("error sending notification to user: {}", userId);
                emitters.remove(userId);
            }
        }
    }
}