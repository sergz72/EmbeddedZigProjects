using System.Security.Cryptography;
using AesTest;

if (args.Length != 2)
{
    Console.WriteLine("Usage: AesTest ecb|cbc input_file");
    return;
}

var mode = args[0] switch
{
    "ecb" => Mode.Ecb,
    "cbc" => Mode.Cbc,
    "ofb" => Mode.Ofb,
    "cfb" => Mode.Cfb,
    "counter" => Mode.Counter,
    "ccm" => Mode.Ccm,
    "gcm" => Mode.Gcm,
    _ => throw new ArgumentException("Invalid mode")
};

var data = File.ReadAllLines(args[1]);

var state = State.None; 
var parsed = ParseData(data);
Console.WriteLine("key = {0}\niv = {1}\ndata = {2}\nencrypted = {3}",
    BitConverter.ToString(parsed.Key), BitConverter.ToString(parsed.Iv), BitConverter.ToString(parsed.Data),
    BitConverter.ToString(parsed.Encrypted));

var ciphertext = mode switch
{
    Mode.Counter => AesCtrEncrypt(),
    Mode.Ccm => AesCcmEncrypt(),
    Mode.Gcm => AesGcmEncrypt(),
    _ => AesEncrypt()
};
Console.WriteLine("{0} expected={1}", ciphertext.SequenceEqual(parsed.Encrypted) ? "OK" : "ERR", BitConverter.ToString(ciphertext));

return;

byte[] AesCtrEncrypt()
{
    var aes = new AesCtr(parsed.Key, parsed.Iv);
    return aes.Transform(parsed.Data);
}

byte[] AesCcmEncrypt()
{
    var encrypted = new byte[parsed.Data.Length];
    var tag = new byte[16];
    var aes = new AesCcm(parsed.Key);
    aes.Encrypt(parsed.Iv[0..12], parsed.Data, encrypted, tag);
    Console.WriteLine("tag = {0}", BitConverter.ToString(tag));
    return encrypted;
}

byte[] AesGcmEncrypt()
{
    var encrypted = new byte[parsed.Data.Length];
    var tag = new byte[16];
    var aes = new AesGcm(parsed.Key, 16);
    aes.Encrypt(parsed.Iv[0..12], parsed.Data, encrypted, tag);
    Console.WriteLine("tag = {0}", BitConverter.ToString(tag));
    return encrypted;
}

byte[] AesEncrypt()
{
    using var aes = Aes.Create();
    aes.Key = parsed.Key;
    aes.IV = parsed.Iv;
    aes.Padding = PaddingMode.None; // No padding
    aes.Mode = mode switch
    {
        Mode.Ecb => CipherMode.ECB,
        Mode.Cbc => CipherMode.CBC,
        Mode.Ofb => CipherMode.OFB,
        Mode.Cfb => CipherMode.CFB,
        _ => throw new ArgumentOutOfRangeException()
    };
    using var encryptor = aes.CreateEncryptor();
    return encryptor.TransformFinalBlock(parsed.Data, 0, parsed.Data.Length);
}

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
    Cbc,
    Ofb,
    Cfb,
    Counter,
    Ccm,
    Gcm
}

internal struct Parsed
{
    internal byte[] Key;
    internal byte[] Iv;
    internal byte[] Data;
    internal byte[] Encrypted;
}
