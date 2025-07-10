package com.emreonsur.smesales.controller;

import com.emreonsur.smesales.entity.SaleDetail;
import com.emreonsur.smesales.repository.SaleDetailRepository;
import com.emreonsur.smesales.service.SaleDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sale-details")
public class SaleDetailController {
    private final SaleDetailService saleDetailService;
    private final SaleDetailRepository saleDetailRepository;

    @Autowired
    public SaleDetailController(SaleDetailService saleDetailService, SaleDetailRepository saleDetailRepository) {
        this.saleDetailService = saleDetailService;
        this.saleDetailRepository = saleDetailRepository;
    }

    @GetMapping
    public List<SaleDetail> getAllSaleDetails() {
        return saleDetailService.getAllSaleDetails();
    }

    @GetMapping("/{id}")
    public ResponseEntity<SaleDetail> getSaleDetailById(@PathVariable Integer id) {
        return saleDetailService.getSaleDetailById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/sale/{saleId}")
    public List<SaleDetail> getSaleDetailsBySaleId(@PathVariable Integer saleId) {
        return saleDetailService.getSaleDetailsBySaleId(saleId);
    }

    @GetMapping("/product/{productId}")
    public List<SaleDetail> getSaleDetailsByProductId(@PathVariable Integer productId) {
        return saleDetailRepository.findByProduct_Id(productId);
    }

    @PostMapping
    public SaleDetail createSaleDetail(@RequestBody SaleDetail saleDetail) {
        return saleDetailService.createSaleDetail(saleDetail);
    }

    @PutMapping("/{id}")
    public ResponseEntity<SaleDetail> updateSaleDetail(@PathVariable Integer id,
                                                       @RequestBody SaleDetail saleDetail) {
        try {
            SaleDetail updated = saleDetailService.updateSaleDetail(id, saleDetail);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSaleDetail(@PathVariable Integer id) {
        saleDetailService.deleteSaleDetail(id);
        return ResponseEntity.noContent().build();
    }
}