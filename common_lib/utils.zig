pub fn bytesToHex(input: []u8, result: []u8) usize {
    const charset = "0123456789abcdef";
    var idx: usize = 0;
    for (input) |b| {
        result[idx] = charset[b >> 4];
        idx += 1;
        result[idx] = charset[b & 15];
        idx += 1;
        result[idx] = ' ';
        idx += 1;
    }
    return idx;
}
