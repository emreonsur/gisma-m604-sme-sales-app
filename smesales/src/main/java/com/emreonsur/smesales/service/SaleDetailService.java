package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.SaleDetail;

import java.util.List;
import java.util.Optional;

public interface SaleDetailService {
    List<SaleDetail> getAllSaleDetails();

    Optional<SaleDetail> getSaleDetailById(Integer id);

    List<SaleDetail> getSaleDetailsBySaleId(Integer saleId);

    SaleDetail createSaleDetail(SaleDetail saleDetail);

    SaleDetail updateSaleDetail(Integer id, SaleDetail saleDetail);

    void deleteSaleDetail(Integer id);
}