package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.util.Collection;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;


@Entity
@Table(name = "inventorymovement")
@NamedQueries({
    @NamedQuery(name = "Inventorymovement.findAll", query = "SELECT i FROM Inventorymovement i"),
    @NamedQuery(name = "Inventorymovement.findById", query = "SELECT i FROM Inventorymovement i WHERE i.id = :id"),
    @NamedQuery(name = "Inventorymovement.findByMovementDate", query = "SELECT i FROM Inventorymovement i WHERE i.movementDate = :movementDate"),
    @NamedQuery(name = "Inventorymovement.findByAmount", query = "SELECT i FROM Inventorymovement i WHERE i.amount = :amount")})
public class Inventorymovement implements Serializable {

    @Size(max = 11)
    @Column(name = "actionType")
    private String actionType;
    @Size(max = 50)
    @Column(name = "palletSKU")
    private String palletSKU;
    @OneToMany(mappedBy = "inventoryId")
    private Collection<InventorymovementXPallets> inventorymovementXPalletsCollection;
    @JoinColumn(name = "storageFrom", referencedColumnName = "id")
    @ManyToOne
    private Storage storageFrom;
    @JoinColumn(name = "storageTo", referencedColumnName = "id")
    @ManyToOne
    private Storage storageTo;
    @JoinColumn(name = "fromShelf", referencedColumnName = "id")
    @ManyToOne
    private Shelfs fromShelf;
    @JoinColumn(name = "toShelf", referencedColumnName = "id")
    @ManyToOne
    private Shelfs toShelf;
    @JoinColumn(name = "byUser", referencedColumnName = "id")
    @ManyToOne
    private Users byUser;

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

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public String getPalletSKU() {
        return palletSKU;
    }

    public void setPalletSKU(String palletSKU) {
        this.palletSKU = palletSKU;
    }

    public Collection<InventorymovementXPallets> getInventorymovementXPalletsCollection() {
        return inventorymovementXPalletsCollection;
    }

    public void setInventorymovementXPalletsCollection(Collection<InventorymovementXPallets> inventorymovementXPalletsCollection) {
        this.inventorymovementXPalletsCollection = inventorymovementXPalletsCollection;
    }

    public Storage getStorageFrom() {
        return storageFrom;
    }

    public void setStorageFrom(Storage storageFrom) {
        this.storageFrom = storageFrom;
    }

    public Storage getStorageTo() {
        return storageTo;
    }

    public void setStorageTo(Storage storageTo) {
        this.storageTo = storageTo;
    }

    public Shelfs getFromShelf() {
        return fromShelf;
    }

    public void setFromShelf(Shelfs fromShelf) {
        this.fromShelf = fromShelf;
    }

    public Shelfs getToShelf() {
        return toShelf;
    }

    public void setToShelf(Shelfs toShelf) {
        this.toShelf = toShelf;
    }

    public Users getByUser() {
        return byUser;
    }

    public void setByUser(Users byUser) {
        this.byUser = byUser;
    }

}
