/++
    libsodium bindings & wrapper

    libsodium’s license:

    ```
    ISC License

    Copyright (c) 2013-2023
    Frank Denis <j at pureftpd dot org>

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
    ```
 +/
module linedubbed.controller.sodium;

///
final class SodiumException : Exception
{
    ///
    this(string msg = null, string file = __FILE__, size_t line = __LINE__) @safe pure nothrow @nogc
    {
        super(msg, file, line, null);
    }
}

///
ubyte[] genericHash(const(ubyte)[] data) @trusted pure nothrow
{
    auto buffer = new ubyte[](crypto_generichash_BYTES_MAX);
    if (crypto_generichash(buffer.ptr, buffer.length, data.ptr, data.length, null, 0) != 0)
        assert(false, "Sodium call error");

    return buffer;
}

///
bool constTimeMemCmp(T)(const T[] a, const T[] b) @trusted nothrow
in (a.length == b.length)
{
    void[] b1 = cast(void[]) a;
    void[] b2 = cast(void[]) b;
    return (sodium_memcmp(b1.ptr, b2.ptr, b1.length) == 0);
}

///
string bin2hex(const ubyte[] bin) @trusted pure nothrow
{
    immutable size_t outputLength = bin.length * 2;

    immutable size_t hexLen = outputLength + 1;
    auto hex = new char[](hexLen);

    return sodium_bin2hex(hex.ptr, hex.length, bin.ptr, bin.length)[0 .. outputLength];
}

///
ubyte[] hex2bin(string hex) @trusted pure
{
    auto bin = new ubyte[](hex.length / 2);
    size_t binLength = 0;

    if (sodium_hex2bin(bin.ptr, bin.length, hex.ptr, hex.length, null, &binLength, null) != 0)
        throw new SodiumException();

    return bin[0 .. binLength];
}

///
ubyte[] randomBytes(size_t n) @trusted nothrow
{
    auto buffer = new ubyte[](n);
    randombytes_buf(buffer.ptr, buffer.length);
    return buffer;
}

private:

extern (C) nothrow:

void randombytes_buf(const(void*) buf, const size_t size);

int sodium_memcmp(const(const(void)*) b1_, const(const(void)*) b2_, size_t len) pure;

char* sodium_bin2hex(
    const(char*) hex, const size_t hex_maxLen,
    const(ubyte*) bin, const size_t bin_len
) pure;

int sodium_hex2bin(
    const(ubyte*) bin, const size_t bin_maxLen,
    const(const(char)*) hex, const size_t hex_len,
    const(const(char)*) ignore, const(size_t*) bin_len,
    const(const(char)**) hex_end
) pure;

enum crypto_generichash_BYTES_MAX = 64U;

int crypto_generichash(
    ubyte* output, size_t outputLen,
    const(ubyte)* input, ulong inputLen,
    const(ubyte)* key, size_t keyLen
) pure;
