package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.util.Collection;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;


@Entity
@Table(name = "items")
@NamedQueries({
    @NamedQuery(name = "Items.findAll", query = "SELECT i FROM Items i"),
    @NamedQuery(name = "Items.findById", query = "SELECT i FROM Items i WHERE i.id = :id"),
    @NamedQuery(name = "Items.findBySku", query = "SELECT i FROM Items i WHERE i.sku = :sku"),
    @NamedQuery(name = "Items.findByType", query = "SELECT i FROM Items i WHERE i.type = :type"),
    @NamedQuery(name = "Items.findByName", query = "SELECT i FROM Items i WHERE i.name = :name"),
    @NamedQuery(name = "Items.findByAmount", query = "SELECT i FROM Items i WHERE i.amount = :amount"),
    @NamedQuery(name = "Items.findByPrice", query = "SELECT i FROM Items i WHERE i.price = :price"),
    @NamedQuery(name = "Items.findByItemState", query = "SELECT i FROM Items i WHERE i.itemState = :itemState"),
    @NamedQuery(name = "Items.findByTransactionTimestamp", query = "SELECT i FROM Items i WHERE i.transactionTimestamp = :transactionTimestamp"),
    @NamedQuery(name = "Items.findByWeight", query = "SELECT i FROM Items i WHERE i.weight = :weight"),
    @NamedQuery(name = "Items.findBySize", query = "SELECT i FROM Items i WHERE i.size = :size")})
public class Items implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @NotNull
    @Column(name = "id")
    private Integer id;
    @Size(max = 255)
    @Column(name = "sku")
    private String sku;
    @Size(max = 18)
    @Column(name = "type")
    private String type;
    @Size(max = 255)
    @Column(name = "name")
    private String name;
    @Column(name = "amount")
    private Integer amount;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Column(name = "price")
    private Float price;
    @Size(max = 11)
    @Column(name = "itemState")
    private String itemState;
    @Basic(optional = false)
    @NotNull
    @Column(name = "transactionTimestamp")
    @Temporal(TemporalType.TIMESTAMP)
    private Date transactionTimestamp;
    @Column(name = "weight")
    private Float weight;
    @Column(name = "size")
    private Float size;
    @Lob
    @Size(max = 65535)
    @Column(name = "description")
    private String description;
    @OneToMany(mappedBy = "itemId")
    private Collection<InventorymovementXItems> inventorymovementXItemsCollection;
    @OneToMany(mappedBy = "itemId")
    private Collection<ItemsXShelfs> itemsXShelfsCollection;

    public Items() {
    }

    public Items(Integer id) {
        this.id = id;
    }

    public Items(Integer id, Date transactionTimestamp) {
        this.id = id;
        this.transactionTimestamp = transactionTimestamp;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public Float getPrice() {
        return price;
    }

    public void setPrice(Float price) {
        this.price = price;
    }

    public String getItemState() {
        return itemState;
    }

    public void setItemState(String itemState) {
        this.itemState = itemState;
    }

    public Date getTransactionTimestamp() {
        return transactionTimestamp;
    }

    public void setTransactionTimestamp(Date transactionTimestamp) {
        this.transactionTimestamp = transactionTimestamp;
    }

    public Float getWeight() {
        return weight;
    }

    public void setWeight(Float weight) {
        this.weight = weight;
    }

    public Float getSize() {
        return size;
    }

    public void setSize(Float size) {
        this.size = size;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Collection<InventorymovementXItems> getInventorymovementXItemsCollection() {
        return inventorymovementXItemsCollection;
    }

    public void setInventorymovementXItemsCollection(Collection<InventorymovementXItems> inventorymovementXItemsCollection) {
        this.inventorymovementXItemsCollection = inventorymovementXItemsCollection;
    }

    public Collection<ItemsXShelfs> getItemsXShelfsCollection() {
        return itemsXShelfsCollection;
    }

    public void setItemsXShelfsCollection(Collection<ItemsXShelfs> itemsXShelfsCollection) {
        this.itemsXShelfsCollection = itemsXShelfsCollection;
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
        if (!(object instanceof Items)) {
            return false;
        }
        Items other = (Items) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.Items[ id=" + id + " ]";
    }

}
