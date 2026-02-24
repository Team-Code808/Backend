package com.code808.calmdesk.domain.company.service;

import com.code808.calmdesk.domain.company.dto.CompanyDto;

import java.util.List;

public interface CompanyService {
    CompanyDto.CodeResponse generateCode();
    CompanyDto.RegisterResponse register(CompanyDto.RegisterRequest request, String email);
    CompanyDto.CheckResponse getByCode(String CompanyCode);
    CompanyDto.JoinResponse join(CompanyDto.JoinRequest request, String email);

    List<CompanyDto.JoinListItemRes> listAllJoins(Long companyId);
    void approveJoin(Long memberId, String adminEmail);
    void rejectJoin(Long memberId, String adminEmail);

    /**
     * 명함으로 입사 신청 생성 (관리자가 명함 등록 시 "입사 신청으로 등록" 선택한 경우).
     * 이메일이 있으면 기존 회원을 입사 신청 상태로, 없으면 새 회원 생성 후 입사 신청 상태로 등록.
     */
    void createJoinRequestFromBusinessCard(String adminEmail, String name, String email, String phone,
                                           Long departmentId, Long rankId);
}
