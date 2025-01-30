package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.util.Collection;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
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

    public Shelfs() {
    }

    public Shelfs(Integer id) {
        this.id = id;
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
