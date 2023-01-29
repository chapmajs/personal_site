---
layout: post
title: Multipart HTTP POSTs with Groovy's HTTPBuilder
topic: Using HTTPBuilder to make multipart HTTP POSTs to RESTful services
category: programming
description: Groovy's HTTPBuilder, an extension of Apache Commons HttpClient, allows multipart HTML POSTs, but documentation and useful/recent examples are lacking. Here's an example using non-deprecated methods to send multiple files and a few string params to a RESTful service and handle a returned binary.
image: groovy.png
---

We've been working on breaking up a large project into several smaller services linked through RESTful HTTP APIs. One such service transforms several source files and a few string parameters into binary output. This service accepts input as [RFC2388](https://www.ietf.org/rfc/rfc2388.txt) multipart form data. As part of the project, calls from a [Grails](http://www.grails.org)-based frontend have to be submitted to this service, with the results being returned to the user's browser.

The go-to library for making HTTP requests in Groovy is [HTTPBuilder](http://groovy.codehaus.org/HTTP+Builder), a wrapper around Apache Commons [HttpClient](https://hc.apache.org/httpcomponents-client-ga/). It provides an API for building up HTTP requests without working directly with HttpClient, making for cleaner code that doesn't look like someone pasted a bunch of Java into your Groovy service. Unfortunately, available examples seem to stop at trivial cases, bring in a *lot* of HttpClient usage, or rely on deprecated methods.

After reading through examples, HttpClient API documentation, and several other blog posts ([this one](http://dmitrijs.artjomenko.com/2013/06/multipart-file-upload-in-groovy.html) being the most helpful), we now have a service that takes a few String parameters, a Map containing representations of the file components as key:value pairs, and returns a byte array after making a call to our RESTful backend service. Explanation below, code now:

{% codeblock :language => 'groovy', :title => 'Groovy Multipart Post' %}
import groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.POST

import org.apache.commons.io.IOUtils
import org.apache.http.entity.mime.MultipartEntityBuilder
import org.apache.http.entity.mime.content.ByteArrayBody
import org.apache.http.entity.mime.content.StringBody

/**
 * Call out to the backend build service and get byte output.
 * 
 * This service calls our backend RESTful service with a multipart HTTP POST. It receives
 * a byte stream from the service, converting it into a byte array and returning. 
 */
class MultipartPostService {
    private String id
    private String version
    private Map<String, byte[]> components
    private byte[] result

    /**
     * Initialize a MultipartPostService for the ID, version and file components.
     *
     * @param id String representation of the build ID
     * @param version String representation of the build version
     * @param components Map<String, byte[]> of the component files, filenames as keys
     */
    public MultipartPostService (String id, String version, Map<String, byte[]> components) {
        this.id = id
        this.version = version
        this.components = components
    }

    /**
     * Retrieve a binary from a RESTful backend service.
     *
     * @return byte array representation of the service's output
     */
    public byte[] execute () {
        def http = new HTTPBuilder("http://localhost:8080")
      
        http.request (POST) { multipartRequest ->
            uri.path = '/build'

            MultipartEntityBuilder multipartRequestEntity = new MultipartEntityBuilder()
            multipartRequestEntity.addPart('id', new StringBody(id))
            multipartRequestEntity.addPart('version', new StringBody(version))

            components.each { name, contents ->
                multipartRequestEntity.addPart('components', new ByteArrayBody(contents, name))
            }

            multipartRequest.entity = multipartRequestEntity.build()

            response.success = { resp, data ->
                result = IOUtils.toByteArray(data)
            } 

            return result
        }
    }
}
{% endcodeblock %}

Dependencies and Imports
------------------------

For a freshly bootstrapped Grails application, you're going to need to bring in a few extra dependencies to make this work. Here's the dependency list with the versions that were current at the time of writing:

* `org.codehaus.groovy.modules.http-builder:http-builder:0.7.2`
* `org.apache.httpcomponents:httpclient:4.3.5`
* `org.apache.httpcomponents:httpmime:4.3.5`

This gets your the minimum dependencies required to make the above service function. Note that newer versions of HttpClient deprecate classes like `MultipartEntity`. Once you have the required dependencies brought into your project, the following imports will resolve:

{% codeblock :language => 'groovy', :title => 'Imports for Frontend' %}
/* Groovy HTTPBuilder imports */
import groovyx.net.http.HTTPBuilder /* bring in HTTPBuilder */
import static groovyx.net.http.Method.POST /* bring in HTTP methods, we use POST */

/* Apache Commons HttpClient imports */
import org.apache.commons.io.IOUtils /* we use IOUtils to convert the response stream to an array */
import org.apache.http.entity.mime.MultipartEntityBuilder /* we'll use the new builder strategy */
import org.apache.http.entity.mime.content.ByteArrayBody /* this will encapsulate our file uploads */
import org.apache.http.entity.mime.content.StringBody /* this will encapsulate string params */
{% endcodeblock %}

Representing Our Inputs
-----------------------

The service we're POSTing to takes a variable number of files and transforms them into a single binary output. Our Grails frontend is only one of a number of sources that use the REST API, but all API clients typically build up a Map representing the file components before building a multipart request. This Map uses the filenames as keys, with the file's contents as an array of bytes as the value. For the frontend, these components can be processed as the result of a POST to the frontend, as shown below:

{% codeblock :language => 'groovy', :title => 'Processing Multipart Results' %}
def processedComponents = [:]

request.multiFileMap['components'].each { file ->
    processedComponents[file.fileItem.name] = file.bytes
}
{% endcodeblock %}

Representing the file components in this way allows for a single form input accepting a variable number of files. It also makes them easy to rip through, building parts for our multipart POST:

{% codeblock :language => 'groovy', :title => 'Preparing Multipart POST' %}
components.each { name, contents ->
    proofRequestEntity.addPart('components', new ByteArrayBody(contents, name))
}
{% endcodeblock %}

Handling the Results
--------------------

Once the REST API has processed our files, the ID, and the version into a single binary file, it returns a 200 status code and the byte stream. HTTPBuilder handles this by calling a success closure. Providing a closure with an arity of two will result in the response and data stream being bound to the first and second arguments, respectively. The data argument arrives as an InputStream which must be read into a byte array:

{% codeblock :language => 'groovy', :title => 'Handling Multipart Results' %}
response.success = { resp, data ->
    result = IOUtils.toByteArray(data)
}
{% endcodeblock %}

Not too difficult!
