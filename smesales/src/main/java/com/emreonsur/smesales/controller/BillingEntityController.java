package com.emreonsur.smesales.controller;

import com.emreonsur.smesales.entity.BillingEntity;
import com.emreonsur.smesales.repository.BillingEntityRepository;
import com.emreonsur.smesales.service.BillingEntityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/billing-entities")
public class BillingEntityController {

    private final BillingEntityService billingEntityService;
    private final BillingEntityRepository billingEntityRepository;

    @Autowired
    public BillingEntityController(BillingEntityService billingEntityService,
                                   BillingEntityRepository billingEntityRepository) {
        this.billingEntityService = billingEntityService;
        this.billingEntityRepository = billingEntityRepository;
    }

    @GetMapping
    public List<BillingEntity> getAllBillingEntities() {
        return billingEntityService.getAllBillingEntities();
    }

    @GetMapping("/{id}")
    public ResponseEntity<BillingEntity> getBillingEntityById(@PathVariable Integer id) {
        return billingEntityService.getBillingEntityById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/by-trade-name/{tradeName}")
    public ResponseEntity<BillingEntity> getBillingEntityByTradeName(@PathVariable String tradeName) {
        return billingEntityRepository.findByTradeName(tradeName)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/active")
    public List<BillingEntity> getAllActiveBillingEntities() {
        return billingEntityRepository.findByIsActiveTrue();
    }

    @GetMapping("/by-entity-type/{entityType}")
    public List<BillingEntity> getBillingEntitiesByEntityType(@PathVariable String entityType) {
        return billingEntityRepository.findByEntityType(entityType);
    }

    @GetMapping("/exists/{tradeNumberOrCitizenId}")
    public ResponseEntity<Boolean> checkBillingEntityExistsByTradeNumberOrCitizenId(@PathVariable String tradeNumberOrCitizenId) {
        boolean exists = billingEntityRepository.existsByTradeNumberOrCitizenId(tradeNumberOrCitizenId);
        return ResponseEntity.ok(exists);
    }

    @PostMapping
    public BillingEntity createBillingEntity(@RequestBody BillingEntity billingEntity) {
        return billingEntityService.createBillingEntity(billingEntity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<BillingEntity> updateBillingEntity(@PathVariable Integer id,
                                                             @RequestBody BillingEntity billingEntity) {
        try {
            BillingEntity updated = billingEntityService.updateBillingEntity(id, billingEntity);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBillingEntity(@PathVariable Integer id) {
        billingEntityService.deleteBillingEntity(id);
        return ResponseEntity.noContent().build();
    }
}