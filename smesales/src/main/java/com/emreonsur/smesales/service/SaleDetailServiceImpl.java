package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.SaleDetail;
import com.emreonsur.smesales.repository.SaleDetailRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SaleDetailServiceImpl implements SaleDetailService {
    private final SaleDetailRepository saleDetailRepository;

    @Autowired
    public SaleDetailServiceImpl(SaleDetailRepository saleDetailRepository) {
        this.saleDetailRepository = saleDetailRepository;
    }

    @Override
    public List<SaleDetail> getAllSaleDetails() {
        return saleDetailRepository.findAll();
    }

    @Override
    public Optional<SaleDetail> getSaleDetailById(Integer id) {
        return saleDetailRepository.findById(id);
    }

    @Override
    public List<SaleDetail> getSaleDetailsBySaleId(Integer saleId) {
        return saleDetailRepository.findBySale_Id(saleId);
    }

    @Override
    public SaleDetail createSaleDetail(SaleDetail saleDetail) {
        return saleDetailRepository.save(saleDetail);
    }

    @Override
    public SaleDetail updateSaleDetail(Integer id, SaleDetail updatedSaleDetail) {
        return saleDetailRepository.findById(id).map(existingSaleDetail -> {
            existingSaleDetail.setSale(updatedSaleDetail.getSale());
            existingSaleDetail.setProduct(updatedSaleDetail.getProduct());
            existingSaleDetail.setQuantity(updatedSaleDetail.getQuantity());
            existingSaleDetail.setUnitPrice(updatedSaleDetail.getUnitPrice());
            existingSaleDetail.setTotalPrice(updatedSaleDetail.getTotalPrice());
            return saleDetailRepository.save(existingSaleDetail);
        }).orElseThrow(() -> new RuntimeException("SaleDetail not found with id: " + id));
    }

    @Override
    public void deleteSaleDetail(Integer id) {
        saleDetailRepository.deleteById(id);
    }
}