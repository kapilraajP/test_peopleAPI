import ballerina/io;
// import ballerina/log;
import ballerina/task;
import ballerinax/googleapis_people as contacts;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

contacts:GoogleContactsConfiguration googleContactConfig = {oauthClientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: contacts:REFRESH_URL,
        refreshToken: refreshToken
    }};

contacts:Client googleContactClient = check new (googleContactConfig);

int count = 0;
string token = "";
public function main() returns error? {
    task:AppointmentConfiguration configuration = {

        cronExpression: "0/5 * * ? * * *"
    };

    task:Scheduler schedule = check new (configuration);

    check schedule.attach(myService);

    check schedule.start();

    while (true) {}

    check schedule.stop();
}

service object {} myService = service object {

    remote function onTrigger() {
        count += 1;
        if (count > 0) {
            if(token == ""){
                var listPeopleConnection = googleContactClient->getListContactsResponse();
                if (listPeopleConnection is contacts:ConnectionsResponseTr) {
                    io:println(listPeopleConnection.toString());
                    token = listPeopleConnection.nextSyncToken;
                } else {
                    io:println(listPeopleConnection.message());
                }
            } else {
                // io:println("Sync Token ", token);
                var listPeopleConnection = googleContactClient->getListContactsResponse(token);
                if (listPeopleConnection is contacts:ConnectionsResponseTr) {
                    io:println(listPeopleConnection.toString());
                    token = listPeopleConnection.nextSyncToken;
                } else {
                    io:println(listPeopleConnection.message());
                }                
            }                
            io:println("");
        }
    }
};
