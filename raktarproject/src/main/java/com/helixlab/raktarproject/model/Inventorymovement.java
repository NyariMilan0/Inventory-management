package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.util.Collection;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;


@Entity
@Table(name = "inventorymovement")
@NamedQueries({
    @NamedQuery(name = "Inventorymovement.findAll", query = "SELECT i FROM Inventorymovement i"),
    @NamedQuery(name = "Inventorymovement.findById", query = "SELECT i FROM Inventorymovement i WHERE i.id = :id"),
    @NamedQuery(name = "Inventorymovement.findByMovementDate", query = "SELECT i FROM Inventorymovement i WHERE i.movementDate = :movementDate"),
    @NamedQuery(name = "Inventorymovement.findByAmount", query = "SELECT i FROM Inventorymovement i WHERE i.amount = :amount")})
public class Inventorymovement implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "id")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Column(name = "movementDate")
    @Temporal(TemporalType.TIMESTAMP)
    private Date movementDate;
    @Column(name = "amount")
    private Integer amount;
    @OneToMany(mappedBy = "inventoryId")
    private Collection<InventorymovementXStorage> inventorymovementXStorageCollection;
    @OneToMany(mappedBy = "inventoryId")
    private Collection<InventorymovementXItems> inventorymovementXItemsCollection;

    public Inventorymovement() {
    }

    public Inventorymovement(Integer id) {
        this.id = id;
    }

    public Inventorymovement(Integer id, Date movementDate) {
        this.id = id;
        this.movementDate = movementDate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Date getMovementDate() {
        return movementDate;
    }

    public void setMovementDate(Date movementDate) {
        this.movementDate = movementDate;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public Collection<InventorymovementXStorage> getInventorymovementXStorageCollection() {
        return inventorymovementXStorageCollection;
    }

    public void setInventorymovementXStorageCollection(Collection<InventorymovementXStorage> inventorymovementXStorageCollection) {
        this.inventorymovementXStorageCollection = inventorymovementXStorageCollection;
    }

    public Collection<InventorymovementXItems> getInventorymovementXItemsCollection() {
        return inventorymovementXItemsCollection;
    }

    public void setInventorymovementXItemsCollection(Collection<InventorymovementXItems> inventorymovementXItemsCollection) {
        this.inventorymovementXItemsCollection = inventorymovementXItemsCollection;
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
        if (!(object instanceof Inventorymovement)) {
            return false;
        }
        Inventorymovement other = (Inventorymovement) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.Inventorymovement[ id=" + id + " ]";
    }

}
