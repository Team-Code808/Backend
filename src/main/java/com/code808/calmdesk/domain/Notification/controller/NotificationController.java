package com.code808.calmdesk.domain.Notification.controller;

import com.code808.calmdesk.domain.Notification.SseEmitters;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.security.Principal;
import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    // 연결된 클라이언트 관리
    private final SseEmitters sseEmitters;

    @GetMapping(value = "/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter subscribe(@RequestParam String userId) {
        SseEmitter emitter = new SseEmitter(60L * 1000 * 60); // 1시간

        // 🚩 컨트롤러의 Map 대신 sseEmitters 클래스에 추가
        sseEmitters.add(userId, emitter);

        try {
            emitter.send(SseEmitter.event().name("connect").data("connected!"));
        } catch (IOException e) {
            // 에러 발생 시 sseEmitters 내부 로직이 처리하도록 하거나 여기서 직접 삭제
        }
        return emitter;
    }

    /**
     * 2. 알림 목록 조회
     * GET /api/notifications
     */
    @GetMapping("")
    public ResponseEntity<List<?>> getNotifications(Principal principal) {
        // 실제 운영 시: notificationService.getNotifications(principal.getName())
        // 현재는 에러 방지를 위해 빈 리스트 반환
        return ResponseEntity.ok(new ArrayList<>());
    }

    /**
     * 3. 단일 알림 읽음 처리
     * PATCH /api/notifications/{id}/read
     */
    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        // 실제 운영 시: notificationService.markAsRead(id)
        System.out.println("알림 읽음 처리 ID: " + id);
        return ResponseEntity.ok().build();
    }

    /**
     * 4. 모든 알림 읽음 처리
     * POST /api/notifications/read-all
     */
    @PostMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(Principal principal) {
        // 실제 운영 시: notificationService.markAllAsRead(principal.getName())
        System.out.println("모든 알림 읽음 처리: " + principal.getName());
        return ResponseEntity.ok().build();
    }


    }