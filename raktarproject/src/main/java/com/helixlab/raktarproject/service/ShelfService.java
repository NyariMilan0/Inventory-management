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
    
    
    
}
