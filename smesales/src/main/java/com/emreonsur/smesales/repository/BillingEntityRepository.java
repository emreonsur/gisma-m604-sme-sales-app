package com.emreonsur.smesales.repository;

import com.emreonsur.smesales.entity.BillingEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface BillingEntityRepository extends JpaRepository<BillingEntity, Integer> {
    // Find by trade name
    Optional<BillingEntity> findByTradeName(String tradeName);

    // List all active billing entities
    List<BillingEntity> findByIsActiveTrue();

    // List by entity type
    List<BillingEntity> findByEntityType(String entityType);

    // Check if billing entity exists, by trade_number_or_citizen_id
    default boolean existsByTradeNumberOrCitizenId(String tradeNumberOrCitizenId) {
        return false;
    }
}