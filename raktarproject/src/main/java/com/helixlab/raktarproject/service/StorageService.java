package com.helixlab.raktarproject.service;

import com.helixlab.raktarproject.model.Storage;
import org.json.JSONObject;


public class StorageService {
    
    private Storage layer = new Storage();
    
    public void addStorage(String storageName, String location) {
        try {
            Storage.addStorage(storageName, location);
        } catch (Exception e) {
            throw new RuntimeException("Service layer error: " + e.getMessage(), e);
        }
    }
    
    
    
    
    
    
    
    
    
}
