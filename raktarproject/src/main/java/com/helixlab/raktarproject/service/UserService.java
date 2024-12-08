package com.helixlab.raktarproject.service;

import com.helixlab.raktarproject.config.JWT;
import com.helixlab.raktarproject.model.Users;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import org.json.JSONObject;

public class UserService {

    private Users layer = new Users();
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";

    public static boolean isValidEmail(String email) {
        Pattern pattern = Pattern.compile(EMAIL_REGEX);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }

    public static boolean isValidPassword(String password) {
        if (password.length() < 8) {
            return false;
        }

        boolean hasNumber = false;
        boolean hasUpperCase = false;
        boolean hasLowerCase = false;
        boolean hasSpecialChar = false;

        for (char c : password.toCharArray()) {
            if (Character.isDigit(c)) {
                hasNumber = true;
            } else if (Character.isUpperCase(c)) {
                hasUpperCase = true;
            } else if (Character.isLowerCase(c)) {
                hasLowerCase = true;
            } else if ("!@#$%^&*()_+-=[]{}|;':,.<>?/`~".indexOf(c) != -1) {
                hasSpecialChar = true;
            }

        }
        return hasNumber && hasUpperCase && hasLowerCase && hasSpecialChar;
    }

    public JSONObject login(String userName, String password) {
        JSONObject toReturn = new JSONObject();
        String status = "success";
        int statusCode = 200;

        try {
            if (userName == null || userName.isEmpty()) {
                status = "invalidUsername";
                statusCode = 400; // Bad Request
            } else {
                Users modelResult = layer.login(userName, password);
                    JSONObject test = new JSONObject();
                try {
                        test.put("minden", layer.getId());
                        test.put("id", modelResult.getId());
                        test.put("email", modelResult.getEmail());
                        test.put("firstName", modelResult.getFirstName());
                        test.put("jwt", JWT.createJWT(modelResult));
                    } catch (Exception e) {
                        status = "jwtGenerationError";
                        statusCode = 500;
                        e.printStackTrace();
                    }

                    toReturn.put("result", test);

                if (modelResult == null) {
                    status = "userNotFound";
                    statusCode = 404; // Not Found
                } else if (modelResult.getId() == null) {
                    status = "userInvalid";
                    statusCode = 417; // Expectation Failed
                } else {
                    JSONObject result = new JSONObject();
                    result.put("id", modelResult.getId());
                    result.put("email", modelResult.getEmail());
                    result.put("firstName", modelResult.getFirstName());
                    result.put("lastName", modelResult.getLastName());
                    result.put("isAdmin", modelResult.getIsAdmin());
                    result.put("isDeleted", modelResult.getIsDeleted());
                    result.put("picture", modelResult.getPicture());
                    result.put("userName", modelResult.getUserName());

                    try {
                        result.put("jwt", JWT.createJWT(modelResult));
                    } catch (Exception e) {
                        status = "jwtGenerationError";
                        statusCode = 500;
                        e.printStackTrace();
                    }

                    toReturn.put("result", result);
                }
            }
        } catch (Exception e) {
            status = "modelException";
            statusCode = 500; // Internal Server Error
            e.printStackTrace();
        }

        toReturn.put("status", status);
        toReturn.put("statusCode", statusCode);
        return toReturn;
    }

    public JSONObject registerUser(Users u) {
        JSONObject toReturn = new JSONObject();
        String status = "success";
        int statusCode = 200;

        //Az email cím benne van-e a db-ben
        //valid-e az email cím
        //valid-e a jelszó
        if (isValidEmail(u.getEmail())) {
            if (isValidPassword(u.getPassword())) {
                boolean userIsExists = Users.isUserExists(u.getEmail());
                if (Users.isUserExists(u.getEmail()) == null) {
                    status = "ModelException";
                    statusCode = 500;
                } else if (userIsExists == true) {
                    status = "UserAlreadyExists";
                    statusCode = 417;
                } else {
                    boolean registerUser = layer.registerUser(u);
                    if (registerUser == false) {
                        status = "fail";
                        statusCode = 417;
                    }
                }
            } else {
                status = "InvalidPassword";
                statusCode = 417;
            }
        } else {
            status = "InvalidEmail";
            statusCode = 417;
        }

        toReturn.put("status", status);
        toReturn.put("statusCode", statusCode);
        return toReturn;
    }

    public JSONObject registerAdmin(Users u) {
        JSONObject toReturn = new JSONObject();
        String status = "success";
        int statusCode = 200;

        //Az email cím benne van-e a db-ben
        //valid-e az email cím
        //valid-e a jelszó
        if (isValidEmail(u.getEmail())) {
            if (isValidPassword(u.getPassword())) {
                boolean userIsExists = Users.isUserExists(u.getEmail());
                if (Users.isUserExists(u.getEmail()) == null) {
                    status = "ModelException";
                    statusCode = 500;
                } else if (userIsExists == true) {
                    status = "UserAlreadyExists";
                    statusCode = 417;
                } else {
                    boolean registerUser = layer.registerUser(u);
                    if (registerUser == false) {
                        status = "fail";
                        statusCode = 417;
                    }
                }
            } else {
                status = "InvalidPassword";
                statusCode = 417;
            }
        } else {
            status = "InvalidEmail";
            statusCode = 417;
        }

        toReturn.put("status", status);
        toReturn.put("statusCode", statusCode);
        return toReturn;
    }

    public ArrayList<Users> getAllUsers() {
        ArrayList<Users> userList = new ArrayList<>();
        try {
            userList = layer.getAllUsers();

        } catch (Exception e) {
            System.err.println("Error fetching users: " + e.getMessage());
        }

        return userList;
    }

}
