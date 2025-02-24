/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.helixlab.raktarproject.service;

import com.helixlab.raktarproject.model.ShelfCapacitySummaryDTO;
import com.helixlab.raktarproject.model.Shelfs;
import java.util.ArrayList;

/**
 *
 * @author nidid
 */
public class ShelfService {

    private Shelfs layer = new Shelfs();

    public ShelfCapacitySummaryDTO getCapacityByShelfUsage() {
        ShelfCapacitySummaryDTO summary = null;

        try {
            summary = Shelfs.getCapacityByShelfUsage();
        } catch (Exception e) {
            System.err.println("Error fetching shelf capacity summary: " + e.getMessage());
        }

        return summary;
    }

    public Shelfs getShelfsById(Integer id) {
        return layer.getShelfsById(id);
    }

    public Boolean deleteShelfFromStorage(Integer id) {
        Shelfs s = getShelfsById(id);

        if (s != null) {
            return layer.deleteShelfFromStorage(id);
        } else {
            System.err.println("The Shelf doesn't exist");
            return false;
        }
    }

    public void addShelfToStorage(String shelfName, String locationIn, Integer storageId) {
        try {
            Shelfs.addShelfToStorage(shelfName, locationIn, storageId);
        } catch (Exception e) {
            throw new RuntimeException("Service layer error: " + e.getMessage(), e);
        }
    }

}
