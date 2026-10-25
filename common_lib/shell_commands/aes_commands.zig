const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");

const encrypt_command = shell.ShellCommand{
    .name = "aes_encrypt",
    .help = "aes_encrypt implementation_id key_size",
    .parameter_mask = 4,
    .handler = aesEncryptHandler
};

const decrypt_command = shell.ShellCommand{
    .name = "aes_decrypt",
    .help = "aes_decrypt",
    .parameter_mask = 1,
    .handler = aesDecryptHandler
};

pub const Engine = struct {
    encrypt: *const fn([]const u8, []const u8, []const u8, []u8) bool,
    decrypt: *const fn([]const u8, []const u8, []const u8, []u8) bool
};

pub const Engines = struct {
    gen_random: *const fn([]u32) bool,
    implementations: []const Engine,
};

const DATA_SIZE = 16;
var key: [8]u32 = undefined;
var key_length: usize = undefined;
var iv: [4]u32 = undefined;
var encrypted: [DATA_SIZE*4]u8 = undefined;
var engines: *const Engines = undefined;
var implementation_id: usize = undefined;

fn aesEncryptHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    implementation_id = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        _ = try parameters.writer.write("invalid implementation id\n");
        return 1;
    };
    if (implementation_id >= engines.implementations.len) {
        _ = try parameters.writer.write("invalid implementation id\n");
        return 2;
    }
    const key_size = std.fmt.parseInt(usize, parameters.argv[1], 10) catch {
        _ = try parameters.writer.write("invalid key size\n");
        return 3;
    };
    if (key_size != 128 and key_size != 256) {
        _ = try parameters.writer.write("unsupported key size\n");
        return 4;
    }
    key_length = key_size / 32;
    const k = key[0..key_length];
    if (!engines.gen_random(k)) {
        _ = try parameters.writer.write("failed to generate random key\n");
        return 5;
    }
    const kb:[]u8 = std.mem.sliceAsBytes(k);
    _ = try parameters.writer.write("key:\n");
    _ = try utils.printHex(kb, parameters.writer);
    if (!engines.gen_random(&iv)) {
        _ = try parameters.writer.write("failed to generate random iv\n");
        return 6;
    }
    const ib:[]u8 = std.mem.sliceAsBytes(&iv);
    _ = try parameters.writer.write("iv:\n");
    _ = try utils.printHex(ib, parameters.writer);
    var data: [DATA_SIZE]u32 = undefined;
    if (!engines.gen_random(&data)) {
        _ = try parameters.writer.write("failed to generate random data\n");
        return 7;
    }
    const db:[]u8 = std.mem.sliceAsBytes(&data);
    _ = try parameters.writer.write("data:\n");
    _ = try utils.printHex(db, parameters.writer);
    if (!engines.implementations[implementation_id].encrypt(kb, ib, db, &encrypted)) {
        _ = try parameters.writer.write("failed to encrypt data\n");
        return 8;
    }
    _ = try parameters.writer.write("encrypted:\n");
    _ = try utils.printHex(&encrypted, parameters.writer);
    return 0;
}

fn aesDecryptHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    if (implementation_id >= engines.implementations.len) {
        _ = try parameters.writer.write("invalid implementation id\n");
        return 1;
    }
    var data: [DATA_SIZE*4]u8 = undefined;
    const kb:[]u8 = std.mem.sliceAsBytes(key[0..key_length]);
    const ib:[]u8 = std.mem.sliceAsBytes(&iv);
    if (!engines.implementations[implementation_id].decrypt(kb, ib, &encrypted, &data)) {
        _ = try parameters.writer.write("failed to decrypt data\n");
        return 2;
    }
    _ = try parameters.writer.write("decrypted:\n");
    _ = try utils.printHex(&data, parameters.writer);
    return 0;
}

pub fn registerCommands(sh: *shell.Shell, eng: *const Engines) shell.ShellError!void {
    engines = eng;
    try sh.registerCommand(&encrypt_command);
    try sh.registerCommand(&decrypt_command);
}
