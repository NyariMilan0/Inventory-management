package com.helixlab.raktarproject.controller;

import com.helixlab.raktarproject.model.ShelfCapacitySummaryDTO;
import com.helixlab.raktarproject.model.Shelfs;
import com.helixlab.raktarproject.service.ShelfService;
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

@Path("shelfs")
public class ShelfController {

    @Context
    private UriInfo context;
    private ShelfService layer = new ShelfService();

    public ShelfController() {

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

    @GET
    @Path("getCapacityByShelfUsage")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getCapacityByShelfUsage() {
        JSONObject responseObj = new JSONObject();

        try {
            ShelfCapacitySummaryDTO summary = layer.getCapacityByShelfUsage();

            if (summary != null) {
                JSONObject shelfUsageJson = new JSONObject();
                shelfUsageJson.put("currentFreeSpaces", summary.getCurrentFreeSpaces());
                shelfUsageJson.put("maxCapacity", summary.getMaxCapacity());

                responseObj.put("statusCode", 200);
                responseObj.put("shelfUsageSummary", shelfUsageJson);
            } else {
                responseObj.put("statusCode", 404);
                responseObj.put("message", "No data found");
            }

            return Response.ok(responseObj.toString(), MediaType.APPLICATION_JSON).build();

        } catch (Exception e) {
            responseObj.put("statusCode", 500);
            responseObj.put("message", "Failed to retrieve shelf capacity summary");
            responseObj.put("error", e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                           .entity(responseObj.toString())
                           .type(MediaType.APPLICATION_JSON)
                           .build();
        }
    }

}
