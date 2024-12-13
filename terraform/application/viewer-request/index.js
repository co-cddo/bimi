function handler(event) {
    var request = event.request;

    var client_ip = '';
    if (
        typeof (event.viewer) == "object" &&
        typeof (event.viewer['ip']) == "string"
    ) {
        client_ip = event.viewer.ip;
    } else if (
        typeof (request.headers['x-forwarded-for']) == "object"
    ) {
        client_ip = request.headers['x-forwarded-for'].value;
    }

    request.headers['true-client-ip'] = { value: client_ip };

    var host = '';
    if (typeof (request.headers['host']) == "object") {
        host = request.headers['host'].value;
    } else if (typeof (request.headers[':authority']) == "object") {
        host = request.headers[':authority'].value;
    }
    host = host.split(":")[0];
    request.headers['true-host'] = { value: host };

    var ua = '';
    if (typeof (request.headers['user-agent']) == "object") {
        ua = request.headers['user-agent'].value;
    }
    request.headers['true-user-agent'] = { value: ua };

    var norm_uri = (typeof (request.uri) == "string" ? request.uri : "/")
        .toLowerCase()
        .split("?")[0]
        .split("#")[0]
        .replace(/\/+/, '\/');

    if (![
        "bimi.nonprod-service.security.gov.uk",
        "bimi.service.security.gov.uk",
    ].includes(host)) {
        return redirect("https://bimi.service.security.gov.uk" + norm_uri, true, 301, "Moved Permanently");
    }

    if (norm_uri.match(/^(\/.well[-_]known)?\/security(\.txt)?/)) {
        return redirect(
            "https://vulnerability-reporting.service.security.gov.uk/.well-known/security.txt",
            true
        );
    }

    if (norm_uri.match(/^\/.well[-_]known\/hosting(-provider)?/)) {
        return {
            statusCode: 200,
            statusDescription: "OK",
            body: "https://aws.amazon.com/cloudfront/\nhttps://github.com/co-cddo/bimi"
        };
    }

    if (norm_uri.match(/^\/.well[-_]known\/(tea(pot)?|☕|%e2%98%95|coffee)/)) {
        return {
            statusCode: 418,
            statusDescription: "I'm a teapot",
            body: "I'm a teapot"
        };
    }

    if (norm_uri.match(/^\/.well[-_]known\/status/)) {
        return {
            statusCode: 200,
            statusDescription: "OK",
            body: "OK"
        };
    }

    return request;
}

function redirect(url, cache, type, type_string) {
    if (typeof (type) == "undefined") {
        type = 302;
    }
    if (typeof (type_string) == "undefined") {
        type_string = "Found";
    }

    if (typeof (cache) == "undefined") {
        cache = false;
    }

    var response = {
        "statusCode": type,
        "statusDescription": type_string,
        "headers": {
            "location": {
                "value": url
            }
        }
    };

    if (cache) {
        response["headers"]['cache-control'] = {
            value: 'public, max-age=3600, immutable'
        };
    }

    return response;
}

if (typeof (module) === "object") {
    module.exports = handler;
}
