package com.helixlab.raktarproject.service;

import com.helixlab.raktarproject.model.Items;
import com.helixlab.raktarproject.model.Pallets;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;


public class PalletService {
    
    private Pallets layer = new Pallets();
    
    
    public Pallets getPalletsById(Integer id){
        return layer.getPalletsById(id);
    }
    
    public Boolean deletePalletById(Integer id) {
        Pallets u = getPalletsById(id);

        if (u != null) {
            return layer.deletePalletById(id);
        } else {
            System.err.println("The user doesn't exist");
            return false;
        }
    }
    
    public void addPalletToShelf(String skuCode, Integer shelfId, Integer height) {
        try {
            // Validáció: Ellenőrizzük, hogy a SKU létezik-e az items táblában
            EntityManagerFactory emf = Persistence.createEntityManagerFactory("com.helixLab_raktarproject_war_1.0-SNAPSHOTPU");
            EntityManager em = emf.createEntityManager();

            try {
                Query query = em.createQuery("SELECT i FROM Items i WHERE i.sku = :skuCode");
                query.setParameter("skuCode", skuCode);
                Items item = (Items) query.getSingleResult();

                if (item == null) {
                    throw new IllegalArgumentException("SKU code '" + skuCode + "' does not exist in the items table");
                }
            } catch (javax.persistence.NoResultException e) {
                throw new IllegalArgumentException("SKU code '" + skuCode + "' does not exist in the items table");
            } finally {
                em.close();
            }

            // Ha a validáció sikeres, hívjuk meg a model metódust
            Pallets.addPalletToShelf(skuCode, shelfId, height);
        } catch (Exception e) {
            throw new RuntimeException("Service layer error: " + e.getMessage(), e);
        }
    }
}
