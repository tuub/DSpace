/**
 * Make requests to the <a href='http://n2t.net/ezid/'>EZID</a> DOI service,
 * and analyze the responses.
 * 
 * <p>
 * Use {@link EZIDRequestFactory.getInstance} to configure an {@link EZIDRequest}
 * with your authority number and credentials.  {@link EZIDRequest} encapsulates
 * the defined EZID's operations (lookup, create/mint, modify, delete...).
 * An operation returns an {@link EZIDResponse} which gives easy access to
 * EZID's status code and value, status of the underlying HTTP request, and
 * key/value pairs found in the response body (if any).
 * <p>
 */
package org.dspace.identifier.ezid;
