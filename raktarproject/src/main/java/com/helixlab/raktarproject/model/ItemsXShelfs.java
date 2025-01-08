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
@Table(name = "items_x_shelfs")
@NamedQueries({
    @NamedQuery(name = "ItemsXShelfs.findAll", query = "SELECT i FROM ItemsXShelfs i"),
    @NamedQuery(name = "ItemsXShelfs.findById", query = "SELECT i FROM ItemsXShelfs i WHERE i.id = :id")})
public class ItemsXShelfs implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "id")
    private Integer id;
    @JoinColumn(name = "item_id", referencedColumnName = "id")
    @ManyToOne
    private Items itemId;
    @JoinColumn(name = "shelf_id", referencedColumnName = "id")
    @ManyToOne
    private Shelfs shelfId;

    public ItemsXShelfs() {
    }

    public ItemsXShelfs(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Items getItemId() {
        return itemId;
    }

    public void setItemId(Items itemId) {
        this.itemId = itemId;
    }

    public Shelfs getShelfId() {
        return shelfId;
    }

    public void setShelfId(Shelfs shelfId) {
        this.shelfId = shelfId;
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
        if (!(object instanceof ItemsXShelfs)) {
            return false;
        }
        ItemsXShelfs other = (ItemsXShelfs) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.ItemsXShelfs[ id=" + id + " ]";
    }

}
