package com.emreonsur.smesales.repository;

import com.emreonsur.smesales.entity.SaleDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SaleDetailRepository extends JpaRepository<SaleDetail, Integer> {
    // Find sale details by sale ID
    List<SaleDetail> findBySale_Id(Integer saleId);

    // Find sale details by product ID
    List<SaleDetail> findByProduct_Id(Integer productId);
}