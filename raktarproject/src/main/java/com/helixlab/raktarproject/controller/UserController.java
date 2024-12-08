package com.helixlab.raktarproject.controller;

import com.fasterxml.jackson.databind.util.JSONPObject;
import com.helixlab.raktarproject.model.Users;
import com.helixlab.raktarproject.service.UserService;
import java.util.ArrayList;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PUT;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import org.json.JSONArray;
import org.json.JSONObject;

@Path("user")
public class UserController {

    @Context
    private UriInfo context;
    private UserService layer = new UserService();

    public UserController() {

    }

    @GET
    @Produces(MediaType.APPLICATION_XML)
    public String getXml() {
        //TODO return proper representation object
        throw new UnsupportedOperationException();
    }

    @PUT
    @Produces(MediaType.APPLICATION_XML)
    public void putXml(String content) {

    }

    @POST
    @Path("login")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(String bodyString) {
        JSONObject body = new JSONObject(bodyString);

        JSONObject obj = layer.login(body.getString("userName"), body.getString("password"));
        return Response.status(obj.getInt("statusCode")).entity(obj.toString()).type(MediaType.APPLICATION_JSON).build();
    }

    @POST
    @Path("registerUser")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response registerUser(String bodyString) {
        JSONObject body = new JSONObject(bodyString);

        Users u = new Users(
                body.getString("email"),
                body.getString("firstName"),
                body.getString("lastName"),
                body.getString("userName"),
                body.getString("picture"),
                body.getString("password")
        );

        JSONObject obj = layer.registerUser(u);
        return Response.status(obj.getInt("statusCode")).entity(obj.toString()).type(MediaType.APPLICATION_JSON).build();
    }

    @POST
    @Path("registerAdmin")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response registerAdmin(String bodyString) {
        JSONObject body = new JSONObject(bodyString);

        Users u = new Users(
                body.getString("email"),
                body.getString("firstName"),
                body.getString("lastName"),
                body.getString("userName"),
                body.getString("picture"),
                body.getString("password")
        );

        JSONObject obj = layer.registerUser(u);
        return Response.status(obj.getInt("statusCode")).entity(obj.toString()).type(MediaType.APPLICATION_JSON).build();
    }

    @GET
    @Path("getAllUsers")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllUsers() {
        JSONObject responseObj = new JSONObject();

        try {
            // Call the service to get the list of users
            ArrayList<Users> userList = layer.getAllUsers();  // Assuming layer.getAllUsers() returns an ArrayList<User>

            // Initialize a JSON array to store user data
            JSONArray usersArray = new JSONArray();

            // Iterate over the user list and convert each user to a JSONObject
            for (Users u : userList) {
                JSONObject userJson = new JSONObject();
                userJson.put("id", u.getId());
                userJson.put("email", u.getEmail());
                userJson.put("firstName", u.getFirstName());
                userJson.put("lastName", u.getLastName());
                userJson.put("password", u.getPassword());
                userJson.put("isAdmin", u.getIsAdmin());  // Method to get boolean field isAdmin
                userJson.put("userName", u.getUserName());  // Method to get boolean field isAdmin
                userJson.put("isDeleted", u.getIsDeleted());  // Method to get boolean field isDeleted
                userJson.put("createdAt", u.getCreatedAt());
                userJson.put("deletedAt", u.getDeletedAt());
                userJson.put("picture", u.getPicture());

                // Add the user JSON object to the array
                usersArray.put(userJson);
            }

            // Add the users array to the response object
            responseObj.put("statusCode", 200);
            responseObj.put("users", usersArray);

            // Return the response with a 200 OK status
            return Response.ok(responseObj.toString(), MediaType.APPLICATION_JSON).build();

        } catch (Exception e) {
            // Handle any exceptions
            responseObj.put("statusCode", 500);
            responseObj.put("message", "Failed to retrieve users");
            responseObj.put("error", e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(responseObj.toString()).type(MediaType.APPLICATION_JSON).build();
        }
    }

}
