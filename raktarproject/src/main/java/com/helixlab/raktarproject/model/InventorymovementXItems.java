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
@Table(name = "inventorymovement_x_items")
@NamedQueries({
    @NamedQuery(name = "InventorymovementXItems.findAll", query = "SELECT i FROM InventorymovementXItems i"),
    @NamedQuery(name = "InventorymovementXItems.findById", query = "SELECT i FROM InventorymovementXItems i WHERE i.id = :id")})
public class InventorymovementXItems implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "id")
    private Integer id;
    @JoinColumn(name = "inventory_id", referencedColumnName = "id")
    @ManyToOne
    private Inventorymovement inventoryId;
    @JoinColumn(name = "item_id", referencedColumnName = "id")
    @ManyToOne
    private Items itemId;

    public InventorymovementXItems() {
    }

    public InventorymovementXItems(Integer id) {
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

    public Items getItemId() {
        return itemId;
    }

    public void setItemId(Items itemId) {
        this.itemId = itemId;
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
        if (!(object instanceof InventorymovementXItems)) {
            return false;
        }
        InventorymovementXItems other = (InventorymovementXItems) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.InventorymovementXItems[ id=" + id + " ]";
    }

}
