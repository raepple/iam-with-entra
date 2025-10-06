import com.sap.gateway.ip.core.customdev.util.Message;
import java.util.HashMap;
import groovy.json.JsonSlurper;

def Message processData(Message message) {
    //Get message and parse to json
    def json = message.getBody(java.io.Reader);
    def data = new JsonSlurper().parse(json);

    //get fields of the payload (context & value)
    message.setProperty("contexttype", data.contexttype);
    message.setProperty("contextvalue", data.contextvalue);
    message.setProperty("companycode", data.companycode);
    
    return message;
}