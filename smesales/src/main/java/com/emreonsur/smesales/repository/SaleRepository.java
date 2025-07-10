package com.emreonsur.smesales.repository;

import com.emreonsur.smesales.entity.Sale;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SaleRepository extends JpaRepository<Sale, Integer> {

    // List sales by customer ID
    List<Sale> findByCustomer_Id(Integer customerId);

    // Find sales by invoice ID
    Sale findByInvoiceId(String invoiceId);
}
