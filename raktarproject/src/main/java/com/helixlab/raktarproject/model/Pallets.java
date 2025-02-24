/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.util.Collection;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.Size;

/**
 *
 * @author nidid
 */
@Entity
@Table(name = "pallets")
@NamedQueries({
    @NamedQuery(name = "Pallets.findAll", query = "SELECT p FROM Pallets p"),
    @NamedQuery(name = "Pallets.findById", query = "SELECT p FROM Pallets p WHERE p.id = :id"),
    @NamedQuery(name = "Pallets.findByName", query = "SELECT p FROM Pallets p WHERE p.name = :name"),
    @NamedQuery(name = "Pallets.findByCreatedAt", query = "SELECT p FROM Pallets p WHERE p.createdAt = :createdAt"),
    @NamedQuery(name = "Pallets.findByHeight", query = "SELECT p FROM Pallets p WHERE p.height = :height"),
    @NamedQuery(name = "Pallets.findByLength", query = "SELECT p FROM Pallets p WHERE p.length = :length"),
    @NamedQuery(name = "Pallets.findByWidth", query = "SELECT p FROM Pallets p WHERE p.width = :width")})
public class Pallets implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id")
    private Integer id;
    @Size(max = 50)
    @Column(name = "name")
    private String name;
    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
    @Column(name = "height")
    private Integer height;
    @Column(name = "length")
    private Integer length;
    @Column(name = "width")
    private Integer width;
    @OneToMany(mappedBy = "palletId")
    private Collection<PalletsXShelfs> palletsXShelfsCollection;
    @OneToMany(mappedBy = "palletId")
    private Collection<PalletsXItems> palletsXItemsCollection;

    public Pallets() {
    }

    public Pallets(Integer id) {
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

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
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

    public Collection<PalletsXShelfs> getPalletsXShelfsCollection() {
        return palletsXShelfsCollection;
    }

    public void setPalletsXShelfsCollection(Collection<PalletsXShelfs> palletsXShelfsCollection) {
        this.palletsXShelfsCollection = palletsXShelfsCollection;
    }

    public Collection<PalletsXItems> getPalletsXItemsCollection() {
        return palletsXItemsCollection;
    }

    public void setPalletsXItemsCollection(Collection<PalletsXItems> palletsXItemsCollection) {
        this.palletsXItemsCollection = palletsXItemsCollection;
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
        if (!(object instanceof Pallets)) {
            return false;
        }
        Pallets other = (Pallets) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.Pallets[ id=" + id + " ]";
    }
    
}
