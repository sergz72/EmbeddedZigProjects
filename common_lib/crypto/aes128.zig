const AES_BLOCK_SIZE     = 16;
const AES_ROUNDS         = 10;
const AES_ROUND_KEY_SIZE = 176; // AES-128 has 10 rounds, and there is a AddRoundKey before first round. (10+1)x16=176.

// round constants
const RC: [10]u8 = .{0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36};

const SBOX: [256]u8 = .{
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16};

const INV_SBOX: [256]u8 = .{
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d};


// https://en.wikipedia.org/wiki/Finite_field_arithmetic
// Multiply two numbers in the GF(2^8) finite field defined
// by the polynomial x^8 + x^4 + x^3 + x + 1 = 0
// We do use mul2(int8_t a) but not mul(unsigned char a, unsigned char b)
// just in order to get a higher speed.
inline fn mul2(a: u8) u8 {
    return if (a&0x80 != 0) ((a<<1)^0x1b) else (a<<1);
}

fn shiftRows(s: []u8) void {
    @setRuntimeSafety(false);
    var t = s[1]; s[1] = s[5]; s[5] = s[9]; s[9] = s[13]; s[13] = t;
    t = s[2]; s[2] = s[10]; s[10] = t;
    t = s[6]; s[6] = s[14]; s[14] = t;
    t = s[15]; s[15] = s[11]; s[11] = s[7]; s[7] = s[3]; s[3] = t;
}

fn invShiftRows(s: []u8) void {
    @setRuntimeSafety(false);
    var t = s[13]; s[13] = s[9]; s[9] = s[5]; s[5] = s[1]; s[1] = t;
    t = s[2]; s[2] = s[10]; s[10] = t;
    t = s[6]; s[6] = s[14]; s[14] = t;
    t = s[3]; s[3] = s[7]; s[7] = s[11]; s[11] = s[15]; s[15] = t;
}

pub const Aes128 = struct {
    round_keys: [AES_ROUND_KEY_SIZE]u8,

    pub fn setKey(self: *Aes128, key: *const [16]u8) void {
        @setRuntimeSafety(false);

        var temp: [4]u8 = undefined;

        @memcpy(self.round_keys[0..16], key);
        
        var idx4: usize = 12;
        for (0..AES_ROUNDS) |i| {
            // k0-k3 for next round
            temp[3] = SBOX[self.round_keys[idx4]];
            idx4 += 1;
            temp[0] = SBOX[self.round_keys[idx4]];
            idx4 += 1;
            temp[1] = SBOX[self.round_keys[idx4]];
            idx4 += 1;
            temp[2] = SBOX[self.round_keys[idx4]];
            idx4 += 1;
            temp[0] ^= RC[i];
            var lastidx = idx4-16;
            var idx = idx4;
            self.round_keys[idx] = temp[0] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1;
            self.round_keys[idx] = temp[1] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1;
            self.round_keys[idx] = temp[2] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1;
            self.round_keys[idx] = temp[3] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1;
            // k4-k7 for next round        
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            // k8-k11 for next round
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            // k12-k15 for next round
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
            self.round_keys[idx] = self.round_keys[idx4] ^ self.round_keys[lastidx]; idx += 1; lastidx += 1; idx4 += 1;
        }
    }

    pub fn encrypt(self: *const Aes128, in: []const u8, out:[]u8) bool {
        @setRuntimeSafety(false);
        if (in.len < AES_BLOCK_SIZE or out.len < AES_BLOCK_SIZE) return false;

        var tmp: [AES_BLOCK_SIZE]u8 = undefined;

        // first AddRoundKey
        var idx: usize = 0;
        for (0..AES_BLOCK_SIZE) |i| {
            out[i] = in[i] ^ self.round_keys[idx]; idx += 1;
        }

        // 9 rounds
        for (1..AES_ROUNDS) |_| {

            // SubBytes
            for (0..AES_BLOCK_SIZE) |i| {
                tmp[i] = SBOX[out[i]];
            }
            shiftRows(&tmp);
            // MixColumns 
            // [02 03 01 01]   [s0  s4  s8  s12]
            // [01 02 03 01] . [s1  s5  s9  s13]
            // [01 01 02 03]   [s2  s6  s10 s14]
            // [03 01 01 02]   [s3  s7  s11 s15]
            var ii: usize = 0;
            while (ii < AES_BLOCK_SIZE) : (ii += 4) {
                const t = tmp[ii] ^ tmp[ii+1] ^ tmp[ii+2] ^ tmp[ii+3];
                out[ii]   = mul2(tmp[ii]   ^ tmp[ii+1]) ^ tmp[ii]   ^ t;
                out[ii+1] = mul2(tmp[ii+1] ^ tmp[ii+2]) ^ tmp[ii+1] ^ t;
                out[ii+2] = mul2(tmp[ii+2] ^ tmp[ii+3]) ^ tmp[ii+2] ^ t;
                out[ii+3] = mul2(tmp[ii+3] ^ tmp[ii]  ) ^ tmp[ii+3] ^ t;
            }

            // AddRoundKey
            for (0..AES_BLOCK_SIZE) |i| {
                out[i] ^= self.round_keys[idx]; idx += 1;
            }
        }
        
        // last round
        for (0..AES_BLOCK_SIZE) |i| {
            out[i] = SBOX[out[i]];
        }
        shiftRows(out);
        for (0..AES_BLOCK_SIZE) |i| {
            out[i] ^= self.round_keys[idx]; idx += 1;
        }

        return true;
    }

    pub fn decrypt(self: *const Aes128, in: []const u8, out:[]u8) bool {
        @setRuntimeSafety(false);
        if (in.len < AES_BLOCK_SIZE or out.len < AES_BLOCK_SIZE) return false;

        var tmp: [AES_BLOCK_SIZE]u8 = undefined;

        // first round
        for (0..AES_BLOCK_SIZE) |i| {
            out[i] = in[i] ^ self.round_keys[i+160];
        }
        invShiftRows(out);
        for (0..AES_BLOCK_SIZE) |i| {
            out[i] = INV_SBOX[out[i]];
        }

        var idx: usize = 160-16;
        for (1..AES_ROUNDS) |_| {
            
            // Inverse AddRoundKey
            for (0..AES_BLOCK_SIZE) |i| {
                tmp[i] = out[i] ^ self.round_keys[idx + i];
            }
            
            // Inverse MixColumns
            // [0e 0b 0d 09]   [s0  s4  s8  s12]
            // [09 0e 0b 0d] . [s1  s5  s9  s13]
            // [0d 09 0e 0b]   [s2  s6  s10 s14]
            // [0b 0d 09 0e]   [s3  s7  s11 s15]
            var ii: usize = 0;
            while (ii < AES_BLOCK_SIZE) : (ii += 4) {
                var t = tmp[ii] ^ tmp[ii+1] ^ tmp[ii+2] ^ tmp[ii+3];
                out[ii]   = t ^ tmp[ii]   ^ mul2(tmp[ii]   ^ tmp[ii+1]);
                out[ii+1] = t ^ tmp[ii+1] ^ mul2(tmp[ii+1] ^ tmp[ii+2]);
                out[ii+2] = t ^ tmp[ii+2] ^ mul2(tmp[ii+2] ^ tmp[ii+3]);
                out[ii+3] = t ^ tmp[ii+3] ^ mul2(tmp[ii+3] ^ tmp[ii]);
                const u = mul2(mul2(tmp[ii]   ^ tmp[ii+2]));
                const v = mul2(mul2(tmp[ii+1] ^ tmp[ii+3]));
                t = mul2(u ^ v);
                out[ii]   ^= t ^ u;
                out[ii+1] ^= t ^ v;
                out[ii+2] ^= t ^ u;
                out[ii+3] ^= t ^ v;
            }
            
            // Inverse ShiftRows
            invShiftRows(out);
            
            // Inverse SubBytes
            for (0..AES_BLOCK_SIZE) |i| {
                out[i] = INV_SBOX[out[i]];
            }

            idx -= 16;
        }

        // last AddRoundKey
        for (0..AES_BLOCK_SIZE) |i| {
            out[i] ^= self.round_keys[i];
        }

        return true;
    }

    pub fn encryptCbc(self: *const Aes128, iv: *const [16]u8, data:[]const u8, encrypted: []u8) bool {
        if (data.len != encrypted.len or data.len & 0x0F != 0) {
            return false;
        }
        if (data.len == 0) {
            return true;
        }
        var prev_block: [16]u8 = undefined;
        @memcpy(&prev_block, iv);

        var i: usize = 0;
        while (i < data.len) : (i += 16) {
            var current_block: [16]u8 = undefined;

            for (0..16) |j| {
                current_block[j] = data[i + j] ^ prev_block[j];
            }

            if (!self.encrypt(&current_block, encrypted[i..])) {
                return false;
            }

            @memcpy(&prev_block, encrypted[i..i+16]);
        }
        return true;
    }

    pub fn decryptCbc(self: *const Aes128, iv: *const [16]u8, data:[]const u8, decrypted: []u8) bool {
        if (data.len != decrypted.len or data.len & 0x0F != 0) {
            return false;
        }
        if (data.len == 0) {
            return true;
        }
        var prev_block: [16]u8 = undefined;
        @memcpy(&prev_block, iv);

        var i: usize = 0;
        while (i < data.len) : (i += 16) {
            var decrypted_block: [16]u8 = undefined;

            if (!self.decrypt(data[i..], &decrypted_block)) {
                return false;
            }

            for (0..16) |j| {
                decrypted[i + j] = decrypted_block[j] ^ prev_block[j];
            }

            @memcpy(&prev_block, data[i..i+16]);
        }
        return true;
    }
};

test "AES-128 key expansion FIPS-197" {
    const std = @import("std");

    const key = [_]u8{
        0x2b, 0x7e, 0x15, 0x16,
        0x28, 0xae, 0xd2, 0xa6,
        0xab, 0xf7, 0x15, 0x88,
        0x09, 0xcf, 0x4f, 0x3c
    };

    const expected = [_]u8{
        // Round key 0
        0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6,
        0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c,

        // Round key 1
        0xa0, 0xfa, 0xfe, 0x17, 0x88, 0x54, 0x2c, 0xb1,
        0x23, 0xa3, 0x39, 0x39, 0x2a, 0x6c, 0x76, 0x05,

        // Round key 2
        0xf2, 0xc2, 0x95, 0xf2, 0x7a, 0x96, 0xb9, 0x43,
        0x59, 0x35, 0x80, 0x7a, 0x73, 0x59, 0xf6, 0x7f,

        // Round key 3
        0x3d, 0x80, 0x47, 0x7d, 0x47, 0x16, 0xfe, 0x3e,
        0x1e, 0x23, 0x7e, 0x44, 0x6d, 0x7a, 0x88, 0x3b,

        // Round key 4
        0xef, 0x44, 0xa5, 0x41, 0xa8, 0x52, 0x5b, 0x7f,
        0xb6, 0x71, 0x25, 0x3b, 0xdb, 0x0b, 0xad, 0x00,

        // Round key 5
        0xd4, 0xd1, 0xc6, 0xf8, 0x7c, 0x83, 0x9d, 0x87,
        0xca, 0xf2, 0xb8, 0xbc, 0x11, 0xf9, 0x15, 0xbc,

        // Round key 6
        0x6d, 0x88, 0xa3, 0x7a, 0x11, 0x0b, 0x3e, 0xfd,
        0xdb, 0xf9, 0x86, 0x41, 0xca, 0x00, 0x93, 0xfd,

        // Round key 7
        0x4e, 0x54, 0xf7, 0x0e, 0x5f, 0x5f, 0xc9, 0xf3,
        0x84, 0xa6, 0x4f, 0xb2, 0x4e, 0xa6, 0xdc, 0x4f,

        // Round key 8
        0xea, 0xd2, 0x73, 0x21, 0xb5, 0x8d, 0xba, 0xd2,
        0x31, 0x2b, 0xf5, 0x60, 0x7f, 0x8d, 0x29, 0x2f,

        // Round key 9
        0xac, 0x77, 0x66, 0xf3, 0x19, 0xfa, 0xdc, 0x21,
        0x28, 0xd1, 0x29, 0x41, 0x57, 0x5c, 0x00, 0x6e,

        // Round key 10
        0xd0, 0x14, 0xf9, 0xa8, 0xc9, 0xee, 0x25, 0x89,
        0xe1, 0x3f, 0x0c, 0xc8, 0xb6, 0x63, 0x0c, 0xa6,
    };

    var aes: Aes128 = undefined;
    aes.setKey(&key);

    try std.testing.expectEqualSlices(
        u8,
        &expected,
        &aes.round_keys,
    );
}

test "AES-128 NIST known-answer vector" {
    const std = @import("std");

    const key = [_]u8{
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    };
    const plaintext = [_]u8{
        0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
        0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff,
    };
    const expected = [_]u8{
        0x69, 0xc4, 0xe0, 0xd8, 0x6a, 0x7b, 0x04, 0x30,
        0xd8, 0xcd, 0xb7, 0x80, 0x70, 0xb4, 0xc5, 0x5a,
    };

    var aes: Aes128 = undefined;
    aes.setKey(&key);
    var encrypted: [AES_BLOCK_SIZE]u8 = undefined;
    _  = aes.encrypt(&plaintext, &encrypted);
    //var ectx = std.crypto.core.aes.Aes128.initEnc(key);
    //ectx.encrypt(&encrypted, &plaintext);
    try std.testing.expectEqualSlices(u8, &expected, &encrypted);

    var decrypted: [AES_BLOCK_SIZE]u8 = undefined;
    _ = aes.decrypt(&encrypted, &decrypted);
    //var dctx = std.crypto.core.aes.Aes128.initDec(key);
    //dctx.decrypt(&decrypted, &encrypted);
    try std.testing.expectEqualSlices(u8, &plaintext, &decrypted);
}

test "AES-128-CBC 64-byte fixed round-trip" {
    const std = @import("std");

    const key = [16]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    const iv = [16]u8{ 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 };

    const plaintext = [64]u8{
        1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
        33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
        49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64
    };

    var ciphertext: [64]u8 = undefined;
    var decrypted: [64]u8 = undefined;

    var aes: Aes128 = undefined;
    aes.setKey(&key);

    try std.testing.expect(aes.encryptCbc(&iv, &plaintext, &ciphertext));

    try std.testing.expect(!std.mem.eql(u8, &ciphertext, &plaintext));

    try std.testing.expect(aes.decryptCbc(&iv, &ciphertext, &decrypted));

    try std.testing.expectEqualSlices(u8, &plaintext, &decrypted);
}