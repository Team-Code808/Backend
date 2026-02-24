package com.code808.calmdesk.global.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;

/**
 * Ollama 명함 추출 시 비전 모델(llava 등) 응답이 느려서 Read timed out 이 나는 경우를 위해
 * RestClient 읽기/연결 타임아웃을 늘림. app.business-card.ai.provider=ollama 일 때만 적용.
 */
@Configuration
@ConditionalOnProperty(name = "app.business-card.ai.provider", havingValue = "ollama")
public class OllamaClientConfig {

    private static final Duration OLLAMA_TIMEOUT = Duration.ofMinutes(5);

    @Bean
    @Primary
    public RestClient.Builder restClientBuilder() {
        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(OLLAMA_TIMEOUT)
                .build();
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(OLLAMA_TIMEOUT);
        return RestClient.builder().requestFactory(requestFactory);
    }
}
