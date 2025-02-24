/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

/**
 *
 * @author nidid
 */
@Entity
@Table(name = "movement_requests")
@NamedQueries({
    @NamedQuery(name = "MovementRequests.findAll", query = "SELECT m FROM MovementRequests m"),
    @NamedQuery(name = "MovementRequests.findById", query = "SELECT m FROM MovementRequests m WHERE m.id = :id"),
    @NamedQuery(name = "MovementRequests.findByAdminId", query = "SELECT m FROM MovementRequests m WHERE m.adminId = :adminId"),
    @NamedQuery(name = "MovementRequests.findByPalletId", query = "SELECT m FROM MovementRequests m WHERE m.palletId = :palletId"),
    @NamedQuery(name = "MovementRequests.findByFromShelfId", query = "SELECT m FROM MovementRequests m WHERE m.fromShelfId = :fromShelfId"),
    @NamedQuery(name = "MovementRequests.findByToShelfId", query = "SELECT m FROM MovementRequests m WHERE m.toShelfId = :toShelfId"),
    @NamedQuery(name = "MovementRequests.findByActionType", query = "SELECT m FROM MovementRequests m WHERE m.actionType = :actionType"),
    @NamedQuery(name = "MovementRequests.findByStatus", query = "SELECT m FROM MovementRequests m WHERE m.status = :status"),
    @NamedQuery(name = "MovementRequests.findByTimeLimit", query = "SELECT m FROM MovementRequests m WHERE m.timeLimit = :timeLimit")})
public class MovementRequests implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id")
    private Integer id;
    @Basic(optional = false)
    @NotNull
    @Column(name = "adminId")
    private int adminId;
    @Basic(optional = false)
    @NotNull
    @Column(name = "pallet_id")
    private int palletId;
    @Column(name = "fromShelfId")
    private Integer fromShelfId;
    @Column(name = "toShelfId")
    private Integer toShelfId;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 100)
    @Column(name = "actionType")
    private String actionType;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 11)
    @Column(name = "status")
    private String status;
    @Basic(optional = false)
    @NotNull
    @Column(name = "timeLimit")
    @Temporal(TemporalType.TIMESTAMP)
    private Date timeLimit;

    public MovementRequests() {
    }

    public MovementRequests(Integer id) {
        this.id = id;
    }

    public MovementRequests(Integer id, int adminId, int palletId, String actionType, String status, Date timeLimit) {
        this.id = id;
        this.adminId = adminId;
        this.palletId = palletId;
        this.actionType = actionType;
        this.status = status;
        this.timeLimit = timeLimit;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public int getAdminId() {
        return adminId;
    }

    public void setAdminId(int adminId) {
        this.adminId = adminId;
    }

    public int getPalletId() {
        return palletId;
    }

    public void setPalletId(int palletId) {
        this.palletId = palletId;
    }

    public Integer getFromShelfId() {
        return fromShelfId;
    }

    public void setFromShelfId(Integer fromShelfId) {
        this.fromShelfId = fromShelfId;
    }

    public Integer getToShelfId() {
        return toShelfId;
    }

    public void setToShelfId(Integer toShelfId) {
        this.toShelfId = toShelfId;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getTimeLimit() {
        return timeLimit;
    }

    public void setTimeLimit(Date timeLimit) {
        this.timeLimit = timeLimit;
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
        if (!(object instanceof MovementRequests)) {
            return false;
        }
        MovementRequests other = (MovementRequests) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.MovementRequests[ id=" + id + " ]";
    }
    
}
