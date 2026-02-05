package com.code808.calmdesk.domain.Notification.service;

import com.code808.calmdesk.domain.Notification.SseEmitters;
import com.code808.calmdesk.domain.Notification.entity.Notification;
import com.code808.calmdesk.domain.Notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;
    private final SseEmitters sseEmitters; // SSE 연결 관리 객체 (별도 구현 필요)

    @Transactional
    public void send(String memberId, String type, String title, String message) {
        // 1. DB 저장
        Notification notification = Notification.builder()
                .memberId(memberId)
                .type(type)
                .title(title)
                .message(message)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();
        notificationRepository.save(notification);

        // 2. 실시간 전송 (SSE)
        sseEmitters.sendToClient(memberId, notification);
    }


    @Transactional
    public void createNotification(String memberId, String type, String title, String message) {
        // 1. 알림 엔티티 생성 및 DB 저장
        Notification notification = Notification.builder()
                .memberId(memberId)
                .type(type)
                .title(title)
                .message(message)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();

        notificationRepository.save(notification);

        // 2. 실시간 전송 (접속 중인 경우)
        sseEmitters.sendToClient(memberId, notification);
    }

}