function handler(event) {
    var response = event.response;

    if (typeof (response) == "undefined") {
        console.log("handler: WARNING event.response UNDEFINED! Ensure this function is set to viewer response.");
        if (typeof (event.request) != "undefined") {
            return event.request;
        }
        return;
    }

    var uri = typeof (event.request) == "undefined" ? "/" : (
        typeof (event.request.uri) == "undefined" ? "/" : event.request.uri
    );
    
    var max_age_cache = 3600;
    if (
        uri.indexOf(".pem") !== -1
        || uri.indexOf(".svg") !== -1
    ) {
        max_age_cache = 31556952;
    }

    var headers = response.headers;

    var currentHeaderKeys = Object.keys(headers);

    if ('server' in headers) {
        delete headers['server'];
    }
    if ('x-powered-by' in headers) {
        delete headers['x-powered-by'];
    }

    if (!currentHeaderKeys.includes('cache-control')) {
        headers['cache-control'] = {
            value: max_age_cache !== 0 ? "public, max-age=" + max_age_cache : "private, no-store, max-age=0"
        };
    }

    if (!currentHeaderKeys.includes('strict-transport-security')) {
        headers['strict-transport-security'] = { value: "max-age=31536000; includeSubdomains; preload" };
    }

    if (!currentHeaderKeys.includes('content-security-policy')) {
        headers['content-security-policy'] = { value: "default-src 'self';" };
    }

    if (!currentHeaderKeys.includes('x-content-type-options')) {
        headers['x-content-type-options'] = { value: "nosniff" };
    }

    if (!currentHeaderKeys.includes('x-frame-options')) {
        headers['x-frame-options'] = { value: "DENY" };
    }

    if (!currentHeaderKeys.includes('referrer-policy')) {
        headers['referrer-policy'] = { value: "strict-origin-when-cross-origin" };
    }

    var perms = [
        ["geolocation", null],
        ["microphone", null],
        ["camera", null],
        ["payment", null],
        ["xr-spatial-tracking", null],
        ["magnetometer", null],
        ["payment", null],
        ["sync-xhr", "'self'"],
    ];

    if (!currentHeaderKeys.includes('permissions-policy')) {
        headers['permissions-policy'] = {
            // format: feature1=(sources), feature2=(sources)
            value: perms.map(p => p[0] + "=(" + (
                p[1] == null ? "" : p[1].replace("'self'", "self")
            ) + ")").join(", ")
        };
    }

    if (!currentHeaderKeys.includes('feature-policy')) {
        headers['feature-policy'] = {
            // format: feature1 sources; feature2 sources;
            value: perms.map(p => p[0] + " " + (p[1] == null ? "'none'" : p[1])).join("; ")
        };
    }

    if (!currentHeaderKeys.includes('cross-origin-embedder-policy')) {
        headers['cross-origin-embedder-policy'] = { value: "unsafe-none" };
    }

    if (!currentHeaderKeys.includes('cross-origin-opener-policy')) {
        headers['cross-origin-opener-policy'] = { value: "same-origin" };
    }

    if (!currentHeaderKeys.includes('cross-origin-resource-policy')) {
        headers['cross-origin-resource-policy'] = { value: "cross-origin" };
    }

    if (!currentHeaderKeys.includes('access-control-allow-headers')) {
        headers['access-control-allow-headers'] = { value: "*" };
    }

    if (!currentHeaderKeys.includes('access-control-allow-origin')) {
        headers['access-control-allow-origin'] = { value: "*" };
    }

    if (!currentHeaderKeys.includes('access-control-allow-methods')) {
        headers['access-control-allow-methods'] = { value: "GET, HEAD" };
    }

    //Return modified response
    return response;
}

if (typeof (module) === "object") {
    module.exports = handler;
}
