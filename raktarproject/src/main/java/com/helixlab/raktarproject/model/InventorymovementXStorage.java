package com.helixlab.raktarproject.model;

import java.io.Serializable;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;


@Entity
@Table(name = "inventorymovement_x_storage")
@NamedQueries({
    @NamedQuery(name = "InventorymovementXStorage.findAll", query = "SELECT i FROM InventorymovementXStorage i"),
    @NamedQuery(name = "InventorymovementXStorage.findById", query = "SELECT i FROM InventorymovementXStorage i WHERE i.id = :id")})
public class InventorymovementXStorage implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "id")
    private Integer id;
    @JoinColumn(name = "inventory_id", referencedColumnName = "id")
    @ManyToOne
    private Inventorymovement inventoryId;
    @JoinColumn(name = "fromStorage_id", referencedColumnName = "id")
    @ManyToOne
    private Storage fromStorageid;
    @JoinColumn(name = "toStorage_id", referencedColumnName = "id")
    @ManyToOne
    private Storage toStorageid;

    public InventorymovementXStorage() {
    }

    public InventorymovementXStorage(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Inventorymovement getInventoryId() {
        return inventoryId;
    }

    public void setInventoryId(Inventorymovement inventoryId) {
        this.inventoryId = inventoryId;
    }

    public Storage getFromStorageid() {
        return fromStorageid;
    }

    public void setFromStorageid(Storage fromStorageid) {
        this.fromStorageid = fromStorageid;
    }

    public Storage getToStorageid() {
        return toStorageid;
    }

    public void setToStorageid(Storage toStorageid) {
        this.toStorageid = toStorageid;
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
        if (!(object instanceof InventorymovementXStorage)) {
            return false;
        }
        InventorymovementXStorage other = (InventorymovementXStorage) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.InventorymovementXStorage[ id=" + id + " ]";
    }

}
