package com.helixlab.raktarproject.controller;

import com.helixlab.raktarproject.service.ShelfService;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriInfo;

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
    
}
