import ballerina/http;

listener http:Listener httpListener = new (8080);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:4200"]
    }
}

service / on httpListener {
    resource function get users() returns User[] {
        return userTable.toArray();
    }

    resource function get users/[string id]() returns User[] | http:NotFound {
        table<User> foundUsers = from User usr in userTable
            where usr.id == id
            select usr;
        if foundUsers.length() > 0 {
            return foundUsers.toArray();
        }
        return http:NOT_FOUND;
    }

    resource function post users(@http:Payload User user) returns http:Created {
        var newID = userTable.length();
        var newUser = user;
        newUser.id = newID.toString();
        userTable.add(user);
        return http:CREATED;
    }

    resource function post users/resetPassword(@http:Payload string emailInput) returns http:Accepted | http:BadRequest {
        table<User> foundUsers = from User usr in userTable 
            where usr.email == emailInput 
            select usr;
        if foundUsers.length() > 0 {
            return http:ACCEPTED;
        }
        return http:BAD_REQUEST;
    }

    resource function post auth/login(@http:Payload LoginData loginData) returns http:Unauthorized | http:Ok {
        table<User> foundUsers = from User usr in userTable
            where usr.email == loginData.email && usr.password == loginData.password
            select usr;
        if foundUsers.length() > 0 {
            return http:OK;
        }
        return http:UNAUTHORIZED;
    }

}

public type LoginData record {|
    string email;
    string password;
|};
public type User record {|
    string id;
    string email;
    string password;
|};

public final table<User> userTable = table [
        {id: "1", email: "user1@mail.com", password: "123"},
        {id: "2", email: "user2@mail.com", password: "123"},
        {id: "3", email: "user3@mail.com", password: "123"}
    ];

