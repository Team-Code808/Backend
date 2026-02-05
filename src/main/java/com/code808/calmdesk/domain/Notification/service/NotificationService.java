package com.code808.calmdesk.domain.Notification.service;

import com.code808.calmdesk.domain.Notification.SseEmitters;
import com.code808.calmdesk.domain.Notification.entity.Notification;
import com.code808.calmdesk.domain.Notification.repository.NotificationRepository;
import com.code808.calmdesk.domain.member.entity.Member;
import com.code808.calmdesk.domain.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;
    private final SseEmitters sseEmitters;
    private final MemberRepository memberRepository;

    /**
     * [핵심 메서드] 알림을 DB에 저장하고 실시간으로 전송합니다.
     * 기존에 createNotification으로 부르던 로직을 saveAndSend로 통합했습니다.
     */
    @Transactional
    public void saveAndSend(String memberId, String type, String title, String message) {
        // 1. DB 저장
        Notification notification = Notification.builder()
                .memberId(memberId)
                .type(type)      // "ADMIN", "USER", "success" 등
                .title(title)
                .message(message)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();

        Notification savedNotification = notificationRepository.save(notification);

        // 2. 실시간 전송 (SSE)
        // savedNotification을 넘겨야 DB에서 생성된 ID가 프론트로 전달됩니다.
        sseEmitters.sendToClient(memberId, savedNotification);
    }

    // 직원용 알림 (saveAndSend 활용)
    public void sendEmployeeNoti(String userId, String msg) {
        saveAndSend(userId, "USER", "개인 알림", msg);
    }

    // 관리자용 알림 (모든 ADMIN에게 전송)
    @Transactional(readOnly = true)
    public void sendAdminNoti(String msg) {
        // DB에서 role이 "ADMIN"인 유저들을 찾습니다.
        // (memberRepository에 findByRole 메서드가 있어야 합니다)
        List<Member> admins = memberRepository.findByRole(Member.Role.ADMIN);

        for (Member admin : admins) {
            saveAndSend(String.valueOf(admin.getMemberId()), "ADMIN", "운영 알림", msg);
        }
    }
}