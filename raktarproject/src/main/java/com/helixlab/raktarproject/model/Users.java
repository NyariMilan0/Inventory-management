package com.helixlab.raktarproject.model;

import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.ParameterMode;
import javax.persistence.Persistence;
import javax.persistence.StoredProcedureQuery;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.Size;


@Entity
@Table(name = "users")
@NamedQueries({
    @NamedQuery(name = "Users.findAll", query = "SELECT u FROM Users u"),
    @NamedQuery(name = "Users.findById", query = "SELECT u FROM Users u WHERE u.id = :id"),
    @NamedQuery(name = "Users.findByEmail", query = "SELECT u FROM Users u WHERE u.email = :email"),
    @NamedQuery(name = "Users.findByFirstName", query = "SELECT u FROM Users u WHERE u.firstName = :firstName"),
    @NamedQuery(name = "Users.findByLastName", query = "SELECT u FROM Users u WHERE u.lastName = :lastName"),
    @NamedQuery(name = "Users.findByUserName", query = "SELECT u FROM Users u WHERE u.userName = :userName"),
    @NamedQuery(name = "Users.findByPassword", query = "SELECT u FROM Users u WHERE u.password = :password"),
    @NamedQuery(name = "Users.findByIsAdmin", query = "SELECT u FROM Users u WHERE u.isAdmin = :isAdmin"),
    @NamedQuery(name = "Users.findByCreatedAt", query = "SELECT u FROM Users u WHERE u.createdAt = :createdAt"),
    @NamedQuery(name = "Users.findByIsDeleted", query = "SELECT u FROM Users u WHERE u.isDeleted = :isDeleted"),
    @NamedQuery(name = "Users.findByDeletedAt", query = "SELECT u FROM Users u WHERE u.deletedAt = :deletedAt")})
public class Users implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id")
    private Integer id;
    // @Pattern(regexp="[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", message="Invalid email")//if the field contains email address consider using this annotation to enforce field validation
    @Size(max = 255)
    @Column(name = "email")
    private String email;
    @Size(max = 255)
    @Column(name = "firstName")
    private String firstName;
    @Size(max = 255)
    @Column(name = "lastName")
    private String lastName;
    @Size(max = 255)
    @Column(name = "userName")
    private String userName;
    @Lob
    @Size(max = 65535)
    @Column(name = "picture")
    private String picture;
    @Size(max = 255)
    @Column(name = "password")
    private String password;
    @Column(name = "isAdmin")
    private Boolean isAdmin;
    @Column(name = "createdAt")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
    @Column(name = "is_deleted")
    private Boolean isDeleted;
    @Column(name = "deletedAt")
    @Temporal(TemporalType.TIMESTAMP)
    private Date deletedAt;
    
    static EntityManagerFactory emf = Persistence.createEntityManagerFactory("com.helixLab_raktarproject_war_1.0-SNAPSHOTPU");


    public Users() {
    }

public Users(Integer id){
        EntityManager em = emf.createEntityManager();
        
        try {
            Users u = em.find(Users.class, id);
            
            this.id = u.getId();
            this.email = u.getEmail();
            this.firstName = u.getFirstName();
            this.lastName = u.getLastName();
            this.password = u.getPassword();
            this.isAdmin = u.getIsAdmin();
            this.userName = u.getUserName();
            this.isDeleted = u.getIsDeleted();
            this.deletedAt = u.getDeletedAt();
            this.createdAt = u.getCreatedAt();
            this.picture = u.getPicture();  
        } catch (Exception ex) {
            System.err.println("Hiba: " + ex.getLocalizedMessage());
        } finally {
            em.clear();
            em.close();
        }
    }

    public Users(Integer id, String email, String firstName, String lastName, String userName, String picture, String password, boolean  isAdmin,Date createdAt, boolean isDeleted, Date deletedAt){
        this.id = id;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
        this.isAdmin = isAdmin;
        this.userName = userName;
        this.isDeleted = isDeleted;
        this.deletedAt = deletedAt;
        this.createdAt = createdAt;
        this.picture = picture;
    }

    public Users(String email, String firstName, String lastName, String picture, String userName, String password) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.userName = userName;
        this.picture = picture;
        this.password = password;
    }

    public Users(String email, String firstName, String lastName, String password, boolean isAdmin) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
        this.isAdmin = isAdmin;
    }
    
    

    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPicture() {
        return picture;
    }

    public void setPicture(String picture) {
        this.picture = picture;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Boolean getIsAdmin() {
        return isAdmin;
    }

    public void setIsAdmin(Boolean isAdmin) {
        this.isAdmin = isAdmin;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Boolean getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(Boolean isDeleted) {
        this.isDeleted = isDeleted;
    }

    public Date getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Date deletedAt) {
        this.deletedAt = deletedAt;
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
        if (!(object instanceof Users)) {
            return false;
        }
        Users other = (Users) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.helixlab.raktarproject.model.Users[ id=" + id + " ]";
    }
    
    public Users login(String userName, String password) {
        EntityManager em = emf.createEntityManager();

        try {
            StoredProcedureQuery spq = em.createStoredProcedureQuery("login");

            spq.registerStoredProcedureParameter("usernameIN", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("passwordIN", String.class, ParameterMode.IN);

            spq.setParameter("usernameIN", userName);
            spq.setParameter("passwordIN", password);

            spq.execute();

            List<Object[]> resultList = spq.getResultList();
            System.out.println("Tömb adatai:" + resultList);
            Users toReturn = new Users();
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            for (Object[] o : resultList) {
                Users u = new Users(
                        Integer.valueOf(o[0].toString()),//id
                        o[1].toString(), //email
                        o[2].toString(), //firstname
                        o[3].toString(), //lastname
                        o[4].toString(), //username
                        o[5].toString(), //picture
                        o[6].toString(), //password
                        Boolean.parseBoolean(o[7].toString()), //isadmin
                        o[8] == null ? null : formatter.parse(o[8].toString()), //creqatedAt
                        Boolean.parseBoolean(o[9].toString()), //isDeleted
                        o[10] == null ? null : formatter.parse(o[10].toString()) //deletedAt
                );
                toReturn = u;
            }

            return toReturn;

        } catch (NumberFormatException | ParseException e) {
            System.err.println("Hiba: " + e.getLocalizedMessage());
            return null;
        } finally {
            em.clear();
            em.close();
        }
    }
    
    public Boolean registerUser(Users u) {
        EntityManager em = emf.createEntityManager();

        try {
            StoredProcedureQuery spq = em.createStoredProcedureQuery("registerUser");

            spq.registerStoredProcedureParameter("emailIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("firstNameIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("lastNameIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("userNameIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("pictureIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("passwordIn", String.class, ParameterMode.IN);

            spq.setParameter("emailIn", u.getEmail());
            spq.setParameter("firstNameIn", u.getFirstName());
            spq.setParameter("lastNameIn", u.getLastName());
            spq.setParameter("userNameIn", u.getUserName());
            spq.setParameter("pictureIn", u.getPicture());
            spq.setParameter("passwordIn", u.getPassword());
            spq.execute();

            return true;
        } catch (Exception e) {
            System.err.println("Hiba: " + e.getLocalizedMessage());
            return false;
        } finally {
            em.clear();
            em.close();
        }
    }
    
    public Boolean registerAdmin(Users u) {
        EntityManager em = emf.createEntityManager();

        try {
            StoredProcedureQuery spq = em.createStoredProcedureQuery("registerAdmin");

            spq.registerStoredProcedureParameter("emailIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("firstNameIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("lastNameIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("userNameIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("pictureIn", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("passwordIn", String.class, ParameterMode.IN);

            spq.setParameter("emailIn", u.getEmail());
            spq.setParameter("firstNameIn", u.getFirstName());
            spq.setParameter("lastNameIn", u.getLastName());
            spq.setParameter("userNameIn", u.getUserName());
            spq.setParameter("pictureIn", u.getPicture());
            spq.setParameter("passwordIn", u.getPassword());
            spq.execute();

            return true;
        } catch (Exception e) {
            System.err.println("Hiba: " + e.getLocalizedMessage());
            return false;
        } finally {
            em.clear();
            em.close();
        }
    }
    
    public static Boolean isUserExists(String email){
        EntityManager em = emf.createEntityManager();
        
        try {
            StoredProcedureQuery spq = em.createStoredProcedureQuery("isUserExist");

            spq.registerStoredProcedureParameter("emailIN", String.class, ParameterMode.IN);
            spq.registerStoredProcedureParameter("resultOUT", Boolean.class, ParameterMode.OUT);
            
            spq.setParameter("emailIN", email);
            
            spq.execute();
            
            Boolean result = Boolean.valueOf(spq.getOutputParameterValue("resultOUT").toString());
            
            return result;
        } catch (Exception e) {
            System.err.println("Hiba: " + e.getLocalizedMessage());
            return null;
        } finally {
            em.clear();
            em.close();
        }
    }
    
    public static ArrayList<Users> getAllUsers() {
    EntityManager em = emf.createEntityManager();
    ArrayList<Users> userList = new ArrayList<>();

    try {
        StoredProcedureQuery spq = em.createStoredProcedureQuery("getAllUsers", Users.class);
        spq.execute();
        userList = new ArrayList<>(spq.getResultList());

    } catch (Exception e) {
        System.err.println("Error: " + e.getLocalizedMessage());
    } finally {
        em.clear();
        em.close();
    }

    return userList;
}
    
    
    
    

}
