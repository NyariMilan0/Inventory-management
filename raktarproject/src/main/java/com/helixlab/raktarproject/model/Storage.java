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
@Table(name = "storage")
@NamedQueries({
    @NamedQuery(name = "Storage.findAll", query = "SELECT s FROM Storage s"),
    @NamedQuery(name = "Storage.findById", query = "SELECT s FROM Storage s WHERE s.id = :id"),
    @NamedQuery(name = "Storage.findByName", query = "SELECT s FROM Storage s WHERE s.name = :name"),
    @NamedQuery(name = "Storage.findByLocation", query = "SELECT s FROM Storage s WHERE s.location = :location"),
    @NamedQuery(name = "Storage.findByIsFull", query = "SELECT s FROM Storage s WHERE s.isFull = :isFull")})
public class Storage implements Serializable {

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
    @Column(name = "location")
    private String location;
    @Column(name = "isFull")
    private Boolean isFull;
    @OneToMany(mappedBy = "fromStorageid")
    private Collection<InventorymovementXStorage> inventorymovementXStorageCollection;
    @OneToMany(mappedBy = "toStorageid")
    private Collection<InventorymovementXStorage> inventorymovementXStorageCollection1;
    @OneToMany(mappedBy = "storageId")
    private Collection<ShelfsXStorage> shelfsXStorageCollection;
    @OneToMany(mappedBy = "storageId")
    private Collection<UserXStorage> userXStorageCollection;

    public Storage() {
    }

    public Storage(Integer id) {
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

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Boolean getIsFull() {
        return isFull;
    }

    public void setIsFull(Boolean isFull) {
        this.isFull = isFull;
    }

    public Collection<InventorymovementXStorage> getInventorymovementXStorageCollection() {
        return inventorymovementXStorageCollection;
    }

    public void setInventorymovementXStorageCollection(Collection<InventorymovementXStorage> inventorymovementXStorageCollection) {
        this.inventorymovementXStorageCollection = inventorymovementXStorageCollection;
    }

    public Collection<InventorymovementXStorage> getInventorymovementXStorageCollection1() {
        return inventorymovementXStorageCollection1;
    }

    public void setInventorymovementXStorageCollection1(Collection<InventorymovementXStorage> inventorymovementXStorageCollection1) {
        this.inventorymovementXStorageCollection1 = inventorymovementXStorageCollection1;
    }

    public Collection<ShelfsXStorage> getShelfsXStorageCollection() {
        return shelfsXStorageCollection;
    }

    public void setShelfsXStorageCollection(Collection<ShelfsXStorage> shelfsXStorageCollection) {
        this.shelfsXStorageCollection = shelfsXStorageCollection;
    }

    public Collection<UserXStorage> getUserXStorageCollection() {
        return userXStorageCollection;
    }

    public void setUserXStorageCollection(Collection<UserXStorage> userXStorageCollection) {
        this.userXStorageCollection = userXStorageCollection;
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
        if (!(object instanceof Storage)) {
            return false;
        }
        Storage other = (Storage) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.Storage[ id=" + id + " ]";
    }

}
