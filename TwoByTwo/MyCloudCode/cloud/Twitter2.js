Parse.Cloud.define("Timeline", function(request, response) {
    var urlLink = 'https://api.twitter.com/1.1/statuses/home_timeline.json';

    var consumerSecret = "VyWrqwPEeNBS9DuqUC7Mhvtymdx3cYcDgvZ7b10ek3K8yVXwDk";
    var tokenSecret = "lYUIyQGJfTlLxjCVCyAWO5o5t5NPV5tYeyhbpDSldPqH2";
    var oauth_consumer_key = "PsAu0NtBDTAypN1Rt24GZODLN";
    var oauth_token = "27076384-vkRsRUEGf9LNREcyUnpJESOHmqqan5vS5hxo9tZD8";

    var nonce = oauth.nonce(32);
    var ts = Math.floor(new Date().getTime() / 1000);
    var timestamp = ts.toString();

    var accessor = {
        "consumerSecret": consumerSecret,
        "tokenSecret": tokenSecret
    };


    var params = {
        "oauth_version": "1.0",
        "oauth_consumer_key": oauth_consumer_key,
        "oauth_token": oauth_token,
        "oauth_timestamp": timestamp,
        "oauth_nonce": nonce,
        "oauth_signature_method": "HMAC-SHA1"
    };
    var message = {
        "method": "GET",
        "action": urlLink,
        "parameters": params
    };


    //lets create signature
    oauth.SignatureMethod.sign(message, accessor);
    var normPar = oauth.SignatureMethod.normalizeParameters(message.parameters);
    console.log("Normalized Parameters: " + normPar);
    var baseString = oauth.SignatureMethod.getBaseString(message);
    console.log("BaseString: " + baseString);
    var sig = oauth.getParameter(message.parameters, "oauth_signature") + "=";
    console.log("Non-Encode Signature: " + sig);
    var encodedSig = oauth.percentEncode(sig); //finally you got oauth signature
    console.log("Encoded Signature: " + encodedSig);

    Parse.Cloud.httpRequest({
        method: 'GET',
        url: urlLink,
        headers: {
            "Authorization": 'OAuth oauth_consumer_key="PsAu0NtBDTAypN1Rt24GZODLN", oauth_nonce=' + nonce + ', oauth_signature=' + encodedSig + ', oauth_signature_method="HMAC-SHA1", oauth_timestamp=' + timestamp + ',oauth_token="27076384-vkRsRUEGf9LNREcyUnpJESOHmqqan5vS5hxo9tZD8", oauth_version="1.0"'
        },
        body: {
        },
        success: function(httpResponse) {
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            response.error('Request failed with response ' + httpResponse.status + ' , ' + httpResponse);
        }
    });
});