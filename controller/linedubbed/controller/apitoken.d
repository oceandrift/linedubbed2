/++
    API Token functions

    Copyright:  Copyright (c) 2023 Elias Batek
    License:    $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:    Elias Batek
 +/
module linedubbed.controller.apitoken;

import linedubbed.controller.sodium;
import std.digest : toHexString;
import std.math : pow;

@safe:

enum b64Variant = Base64Variant.urlsafe;

/++
    API Token generated by the server
 +/
struct ServerToken
{
    /++
        Token data for the API user
     +/
    string userToken;

    /++
        Hash of the token (to store in a database)
     +/
    string hash;
}

/++
    Generates a random API token
 +/
ServerToken apiTokenGen(int complexity)() nothrow
{
    enum length = pow(2, complexity);
    ubyte[] rawToken = randomBytes(length);

    return ServerToken(
        bin2base64(rawToken, b64Variant),
        apiTokenHash(rawToken),
    );
}

/+
    Hashes a raw API token
 +/
private string apiTokenHash(ubyte[] rawToken) pure nothrow
{
    return bin2hex(genericHash(rawToken));
}

/++
    Hashes a user-provided API token
 +/
string apiTokenHash(string userToken) pure
{
    return apiTokenHash(base642bin(userToken, b64Variant));
}

/++
    Compares a user-provided API token against a known hash
 +/
bool apiTokenVerify(string userToken, string knownHash) pure nothrow
{
    string userHash;
    try
        userHash = apiTokenHash(userToken);
    catch (Exception)
        return false;

    return constTimeMemCmp(knownHash, userHash);
}

unittest
{
    // generates a random token and tests it against lib
    auto serverToken = apiTokenGen!10();
    assert(apiTokenVerify(serverToken.userToken, serverToken.hash));
    assert(!apiTokenVerify("ZGVhZGJlZWY=", serverToken.hash));
}

unittest
{
    // test lib with a known token (generated with sodium_crypto_generichash() in PHP)
    string userToken = "rCsVIhm60r7ChtXL4C6ImQ==";
    string hash =
        "4508ff8a3f05ee48ef348ab1d7e606292ded6500f05a0b1a1e01da07a94c407d"
        ~ "39cb571c51feac37df36c11097abc9eb35143976c5e4b5a015bf47db721c1381";

    assert(apiTokenVerify(userToken, hash));
    assert(!apiTokenVerify("qwertz", hash));
    assert(!apiTokenVerify("9842e858535df5f00953a674beb34da2", hash));
}
