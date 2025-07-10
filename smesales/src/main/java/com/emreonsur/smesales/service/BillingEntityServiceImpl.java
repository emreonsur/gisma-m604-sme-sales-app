package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.BillingEntity;
import com.emreonsur.smesales.repository.BillingEntityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BillingEntityServiceImpl implements BillingEntityService {
    private final BillingEntityRepository billingEntityRepository;

    @Autowired
    public BillingEntityServiceImpl(BillingEntityRepository billingEntityRepository) {
        this.billingEntityRepository = billingEntityRepository;
    }

    @Override
    public List<BillingEntity> getAllBillingEntities() {
        return billingEntityRepository.findAll();
    }

    @Override
    public Optional<BillingEntity> getBillingEntityById(Integer id) {
        return billingEntityRepository.findById(id);
    }

    @Override
    public BillingEntity createBillingEntity(BillingEntity billingEntity) {
        return billingEntityRepository.save(billingEntity);
    }

    @Override
    public BillingEntity updateBillingEntity(Integer id, BillingEntity updatedEntity) {
        return billingEntityRepository.findById(id).map(existingEntity -> {
            existingEntity.setTradeNumberOrCitizenId(updatedEntity.getTradeNumberOrCitizenId());
            existingEntity.setEntityType(updatedEntity.getEntityType());
            existingEntity.setTradeName(updatedEntity.getTradeName());
            existingEntity.setTaxOffice(updatedEntity.getTaxOffice());
            existingEntity.setBillingAddress(updatedEntity.getBillingAddress());
            existingEntity.setCurrentBalance(updatedEntity.getCurrentBalance());
            existingEntity.setIsActive(updatedEntity.getIsActive());
            return billingEntityRepository.save(existingEntity);
        }).orElseThrow(() -> new RuntimeException("Billing entity not found with id: " + id));
    }

    @Override
    public void deleteBillingEntity(Integer id) {
        billingEntityRepository.deleteById(id);
    }
}