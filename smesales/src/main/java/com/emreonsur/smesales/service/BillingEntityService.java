package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.BillingEntity;

import java.util.List;
import java.util.Optional;

public interface BillingEntityService {
    List<BillingEntity> getAllBillingEntities();

    Optional<BillingEntity> getBillingEntityById(Integer id);

    BillingEntity createBillingEntity(BillingEntity billingEntity);

    BillingEntity updateBillingEntity(Integer id, BillingEntity billingEntity);

    void deleteBillingEntity(Integer id);
}