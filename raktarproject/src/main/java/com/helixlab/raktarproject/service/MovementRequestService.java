/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.helixlab.raktarproject.service;

import com.helixlab.raktarproject.model.MovementRequests;
import java.util.ArrayList;

/**
 *
 * @author nidid
 */
public class MovementRequestService {

    private MovementRequests layer = new MovementRequests();

    public ArrayList<MovementRequests> getMovementRequests() {
        ArrayList<MovementRequests> movementList = new ArrayList<>();
        try {
            movementList = layer.getMovementRequests();
        } catch (Exception e) {
        System.err.println("Error fetching users: " + e.getMessage());
        }
        return movementList;
    }

}
