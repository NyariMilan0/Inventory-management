package com.helixlab.raktarproject.model;

import static com.helixlab.raktarproject.model.Users.emf;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Persistence;
import javax.persistence.StoredProcedureQuery;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Entity
@Table(name = "shelfs")
@NamedQueries({
    @NamedQuery(name = "Shelfs.findAll", query = "SELECT s FROM Shelfs s"),
    @NamedQuery(name = "Shelfs.findById", query = "SELECT s FROM Shelfs s WHERE s.id = :id"),
    @NamedQuery(name = "Shelfs.findByName", query = "SELECT s FROM Shelfs s WHERE s.name = :name"),
    @NamedQuery(name = "Shelfs.findByLocationInStorage", query = "SELECT s FROM Shelfs s WHERE s.locationInStorage = :locationInStorage"),
    @NamedQuery(name = "Shelfs.findByIsFull", query = "SELECT s FROM Shelfs s WHERE s.isFull = :isFull")})
public class Shelfs implements Serializable {

    @Column(name = "max_capacity")
    private Integer maxCapacity;
    @Column(name = "current_capacity")
    private Integer currentCapacity;
    @Column(name = "height")
    private Integer height;
    @Column(name = "length")
    private Integer length;
    @Column(name = "width")
    private Integer width;
    @Column(name = "levels")
    private Integer levels;
    @OneToMany(mappedBy = "shelfId")
    private Collection<PalletsXShelfs> palletsXShelfsCollection;
    @OneToMany(mappedBy = "fromShelf")
    private Collection<Inventorymovement> inventorymovementCollection;
    @OneToMany(mappedBy = "toShelf")
    private Collection<Inventorymovement> inventorymovementCollection1;

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "id")
    private Integer id;
    @Size(max = 255)
    @Column(name = "name")
    private String name;
    @Lob
    @Size(max = 65535)
    @Column(name = "capacity")
    private String capacity;
    @Size(max = 255)
    @Column(name = "locationInStorage")
    private String locationInStorage;
    @Column(name = "isFull")
    private Boolean isFull;
    @OneToMany(mappedBy = "shelfId")
    private Collection<ShelfsXStorage> shelfsXStorageCollection;

    static EntityManagerFactory emf = Persistence.createEntityManagerFactory("com.helixLab_raktarproject_war_1.0-SNAPSHOTPU");

    public Shelfs() {
    }

    public Shelfs(Integer id) {
        EntityManager em = emf.createEntityManager();

        try {
            Shelfs s = em.find(Shelfs.class, id);

            this.id = s.getId();
            this.name = s.getName();
            this.locationInStorage = s.getLocationInStorage();
            this.maxCapacity = s.getMaxCapacity();
            this.currentCapacity = s.getCurrentCapacity();
            this.height = s.getHeight();
            this.length = s.getLength();
            this.width = s.getWidth();
            this.levels = s.getLevels();
            this.isFull = s.getIsFull();

        } catch (Exception ex) {
            System.err.println("Hiba: " + ex.getLocalizedMessage());
        } finally {
            em.clear();
            em.close();
        }
    }
    
    public Shelfs(Integer currentCapacity, Integer maxCapacity){
        this.currentCapacity = currentCapacity;
        this.maxCapacity = maxCapacity;
    }
    

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCapacity() {
        return capacity;
    }

    public void setCapacity(String capacity) {
        this.capacity = capacity;
    }

    public String getLocationInStorage() {
        return locationInStorage;
    }

    public void setLocationInStorage(String locationInStorage) {
        this.locationInStorage = locationInStorage;
    }

    public Boolean getIsFull() {
        return isFull;
    }

    public void setIsFull(Boolean isFull) {
        this.isFull = isFull;
    }

    public Collection<ShelfsXStorage> getShelfsXStorageCollection() {
        return shelfsXStorageCollection;
    }

    public void setShelfsXStorageCollection(Collection<ShelfsXStorage> shelfsXStorageCollection) {
        this.shelfsXStorageCollection = shelfsXStorageCollection;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Shelfs)) {
            return false;
        }
        Shelfs other = (Shelfs) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.Shelfs[ id=" + id + " ]";
    }

    public Integer getMaxCapacity() {
        return maxCapacity;
    }

    public void setMaxCapacity(Integer maxCapacity) {
        this.maxCapacity = maxCapacity;
    }

    public Integer getCurrentCapacity() {
        return currentCapacity;
    }

    public void setCurrentCapacity(Integer currentCapacity) {
        this.currentCapacity = currentCapacity;
    }

    public Integer getHeight() {
        return height;
    }

    public void setHeight(Integer height) {
        this.height = height;
    }

    public Integer getLength() {
        return length;
    }

    public void setLength(Integer length) {
        this.length = length;
    }

    public Integer getWidth() {
        return width;
    }

    public void setWidth(Integer width) {
        this.width = width;
    }

    public Integer getLevels() {
        return levels;
    }

    public void setLevels(Integer levels) {
        this.levels = levels;
    }
    
    public static ShelfCapacitySummaryDTO getCapacityByShelfUsage() {
        EntityManager em = emf.createEntityManager();
        ShelfCapacitySummaryDTO summary = null;

        try {
            StoredProcedureQuery spq = em.createStoredProcedureQuery("getCapacityByShelfUsage");
            spq.execute();

            List<Object[]> results = spq.getResultList();
            if (!results.isEmpty()) {
                Object[] result = results.get(0);
                summary = new ShelfCapacitySummaryDTO(
                    result[0] != null ? ((Number) result[0]).intValue() : 0, // currentFreeSpaces
                    result[1] != null ? ((Number) result[1]).intValue() : 0  // maxCapacity
                );
            }
        } catch (Exception e) {
            System.err.println("Error: " + e.getLocalizedMessage());
        } finally {
            em.clear();
            em.close();
        }

        return summary;
    }
    

    public Collection<PalletsXShelfs> getPalletsXShelfsCollection() {
        return palletsXShelfsCollection;
    }

    public void setPalletsXShelfsCollection(Collection<PalletsXShelfs> palletsXShelfsCollection) {
        this.palletsXShelfsCollection = palletsXShelfsCollection;
    }

    public Collection<Inventorymovement> getInventorymovementCollection() {
        return inventorymovementCollection;
    }

    public void setInventorymovementCollection(Collection<Inventorymovement> inventorymovementCollection) {
        this.inventorymovementCollection = inventorymovementCollection;
    }

    public Collection<Inventorymovement> getInventorymovementCollection1() {
        return inventorymovementCollection1;
    }

    public void setInventorymovementCollection1(Collection<Inventorymovement> inventorymovementCollection1) {
        this.inventorymovementCollection1 = inventorymovementCollection1;
    }
    
 
    
    
    
    
    
    
    

}
