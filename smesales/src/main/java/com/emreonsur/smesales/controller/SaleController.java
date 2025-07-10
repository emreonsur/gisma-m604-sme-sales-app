package com.emreonsur.smesales.controller;

import com.emreonsur.smesales.entity.Sale;
import com.emreonsur.smesales.repository.SaleRepository;
import com.emreonsur.smesales.service.SaleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sales")
public class SaleController {
    private final SaleService saleService;
    private final SaleRepository saleRepository;

    @Autowired
    public SaleController(SaleService saleService, SaleRepository saleRepository) {
        this.saleService = saleService;
        this.saleRepository = saleRepository;
    }

    @GetMapping
    public List<Sale> getAllSales() {
        return saleService.getAllSales();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Sale> getSaleById(@PathVariable Integer id) {
        return saleService.getSaleById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/by-customer/{customerId}")
    public List<Sale> getSalesByCustomerId(@PathVariable Integer customerId) {
        return saleRepository.findByCustomer_Id(customerId);
    }

    @GetMapping("/by-invoice/{invoiceId}")
    public ResponseEntity<Sale> getSaleByInvoiceId(@PathVariable String invoiceId) {
        Sale sale = saleRepository.findByInvoiceId(invoiceId);
        if (sale != null) {
            return ResponseEntity.ok(sale);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public Sale createSale(@RequestBody Sale sale) {
        return saleService.createSale(sale);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Sale> updateSale(@PathVariable Integer id,
                                           @RequestBody Sale sale) {
        try {
            Sale updated = saleService.updateSale(id, sale);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSale(@PathVariable Integer id) {
        saleService.deleteSale(id);
        return ResponseEntity.noContent().build();
    }
}