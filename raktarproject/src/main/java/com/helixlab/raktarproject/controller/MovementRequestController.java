/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.helixlab.raktarproject.controller;

import com.helixlab.raktarproject.model.MovementRequests;
import com.helixlab.raktarproject.service.MovementRequestService;
import java.util.ArrayList;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import org.json.JSONArray;
import org.json.JSONObject;

@Path("movementrequests")
public class MovementRequestController {

    @Context
    private UriInfo context;
    private MovementRequestService layer = new MovementRequestService();

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

    @GET
    @Path("getMovementRequests")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getMovementRequests() {
        JSONObject responseObj = new JSONObject();

        try {
            ArrayList<MovementRequests> movementList = layer.getMovementRequests();

            JSONArray movementArray = new JSONArray();

            for (MovementRequests mr : movementList) {
                JSONObject movementJSON = new JSONObject();
                movementJSON.put("id", mr.getId());
                movementJSON.put("adminId", mr.getAdminId());
                movementJSON.put("pallet_id", mr.getPalletId());
                movementJSON.put("fromShelfId", mr.getFromShelfId());
                movementJSON.put("toShelfId", mr.getToShelfId());
                movementJSON.put("actionType", mr.getActionType());
                movementJSON.put("status", mr.getStatus());
                movementJSON.put("timeLimit", mr.getTimeLimit());

                movementArray.put(movementJSON);
            }
            responseObj.put("statusCode", 200);
            responseObj.put("MovementRequests", movementArray);

            return Response.ok(responseObj.toString(), MediaType.APPLICATION_JSON).build();

        } catch (Exception e) {
            responseObj.put("statusCode", 500);
            responseObj.put("message", "Failed to retrieve MovementRequests");
            responseObj.put("error", e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(responseObj.toString()).type(MediaType.APPLICATION_JSON).build();
        }
    }
}
