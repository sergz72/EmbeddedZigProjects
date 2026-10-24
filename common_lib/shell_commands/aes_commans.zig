const std = @import("std");
const shell = @import("shell");
const hal = @import("hal");
const utils = @import("utils");

const encrypt_command = shell.ShellCommand{
    .name = "aes_encrypt",
    .help = "aes_encrypt key_size",
    .parameter_mask = 2,
    .handler = aesEncryptHandler
};

const decrypt_command = shell.ShellCommand{
    .name = "aes_decrypt",
    .help = "aes_decrypt",
    .parameter_mask = 1,
    .handler = aesDecryptHandler
};

const DATA_SIZE = 64;
var key: [32]u8 = undefined;
var key_length: usize = undefined;
var iv: [16]u8 = undefined;
var encrypted: [DATA_SIZE]u8 = undefined;

fn aesEncryptHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    const key_size = std.fmt.parseInt(usize, parameters.argv[0], 10) catch {
        _ = try parameters.writer.write("invalid key size\n");
        return 1;
    };
    if (key_size != 128 and key_size != 256) {
        _ = try parameters.writer.write("unsupported key size\n");
        return 2;
    }
    key_length = key_size / 8;
    const k = &key[0..key_length];
    try hal.generateRandomBytes(k) catch {
        _ = try parameters.writer.write("failed to generate random key\n");
        return 3;
    };
    _ = try parameters.writer.write("key:\n");
    _ = try utils.printHex(k, parameters.writer);
    try hal.generateRandomBytes(&iv) catch {
        _ = try parameters.writer.write("failed to generate random iv\n");
        return 3;
    };
    _ = try parameters.writer.write("iv:\n");
    _ = try utils.printHex(&iv, parameters.writer);
    var data: [DATA_SIZE]u8 = undefined;
    try hal.generateRandomBytes(&data) catch {
        _ = try parameters.writer.write("failed to generate random data\n");
        return 4;
    };
    _ = try parameters.writer.write("data:\n");
    _ = try utils.printHex(&data, parameters.writer);
    try hal.aesEncrypt(k, &iv, &data, &encrypted) catch {
        _ = try parameters.writer.write("failed to encrypt data\n");
        return 5;
    };
    _ = try parameters.writer.write("encrypted:\n");
    _ = try utils.printHex(&encrypted, parameters.writer);
    return 0;
}

fn aesDecryptHandler(parameters: shell.ShellHandlerParameters) std.Io.Writer.Error!isize {
    var data: [DATA_SIZE]u8 = undefined;
    try hal.aesDecrypt(&key[0..key_length], &iv, &encrypted, &data) catch {
        _ = try parameters.writer.write("failed to decrypt data\n");
        return 5;
    };
    _ = try parameters.writer.write("decrypted:\n");
    _ = try utils.printHex(&data, parameters.writer);
    return 0;
}

pub fn registerCommands(sh: *shell.Shell) shell.ShellError!void {
    try sh.registerCommand(&encrypt_command);
    try sh.registerCommand(&decrypt_command);
}

