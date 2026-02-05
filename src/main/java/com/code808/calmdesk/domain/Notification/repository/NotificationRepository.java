package com.code808.calmdesk.domain.Notification.repository;

import com.code808.calmdesk.domain.Notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    // 특정 회원의 최신 알림 목록 가져오기
    List<Notification> findByMemberIdOrderByCreatedAtDesc(String memberId);
    
    // 특정 회원의 읽지 않은 알림 개수 확인
    long countByMemberIdAndIsReadFalse(String memberId);

    // 특정 회원의 모든 알림 읽음 처리
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.memberId = :memberId")
    void markAllAsReadByMemberId(String memberId);
}