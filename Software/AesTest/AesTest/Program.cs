using System.Security.Cryptography;

if (args.Length != 2)
{
    Console.WriteLine("Usage: AesTest ecb|cbc input_file");
    return;
}

var mode = args[0] switch
{
    "ecb" => Mode.Ecb,
    "cbc" => Mode.Cbc,
    _ => throw new ArgumentException("Invalid mode")
};

var data = File.ReadAllLines(args[1]);

var state = State.None; 
var parsed = ParseData(data);
Console.WriteLine("key = {0}\ndata={1}\nencrypted={2}",
    BitConverter.ToString(parsed.Key), BitConverter.ToString(parsed.Data), BitConverter.ToString(parsed.Encrypted));

using var aes = Aes.Create();
aes.Key = parsed.Key;
aes.IV = parsed.Iv;
aes.Padding = PaddingMode.None; // No padding
aes.Mode = mode switch
{
    Mode.Ecb => CipherMode.ECB,
    Mode.Cbc => CipherMode.CBC,
    _ => throw new ArgumentOutOfRangeException()
};
using var encryptor = aes.CreateEncryptor();
var ciphertext = encryptor.TransformFinalBlock(parsed.Data, 0, parsed.Data.Length);
Console.WriteLine("{0} expected={1}", ciphertext.SequenceEqual(parsed.Encrypted) ? "OK" : "ERR", BitConverter.ToString(ciphertext));

return;

Parsed ParseData(string[] contents) 
{
    var d = new List<byte>();
    var key = new List<byte>();
    var iv = new List<byte>();
    var encrypted = new List<byte>();
    foreach (var line in contents)
    {
        if (line == "key:")
            state = State.Key;
        else if (line == "iv:")
            state = State.Iv;
        else if (line == "data:")
            state = State.Data;
        else if (line == "encrypted:")
            state = State.Encrypted;
        else
        {
            switch (state)
            {
                case State.Key:
                    ParseHex(line, key);
                    break;
                case State.Iv:
                    ParseHex(line, iv);
                    break;
                case State.Data:
                    ParseHex(line, d);
                    break;
                case State.Encrypted:
                    ParseHex(line, encrypted);
                    break;
                case State.None:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
    return new Parsed
    {
        Data = d.ToArray(),
        Key = key.ToArray(),
        Iv = iv.ToArray(),
        Encrypted = encrypted.ToArray()
    };
}

void ParseHex(string line, List<byte> bytes)
{
    bytes.AddRange(line.Split(' ', StringSplitOptions.RemoveEmptyEntries)
        .Select(b => Convert.ToByte(b, 16)));
}

internal enum State 
{
    None,
    Key,
    Iv,
    Data,
    Encrypted
}

internal enum Mode
{
    Ecb,
    Cbc
}

internal struct Parsed
{
    internal byte[] Key;
    internal byte[] Iv;
    internal byte[] Data;
    internal byte[] Encrypted;
}
