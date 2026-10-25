using System.Security.Cryptography;

if (args.Length != 1)
{
    Console.WriteLine("Usage: AesTest <input_file>");
    return;
}

var data = File.ReadAllLines(args[0]);

var state = State.None; 
var parsed = ParseData(data);
Console.WriteLine("key = {0}\ndata={1}\nencrypted={2}",
    BitConverter.ToString(parsed.Key), BitConverter.ToString(parsed.Data), BitConverter.ToString(parsed.Encrypted));

using var aes = Aes.Create();
aes.Key = parsed.Key;
aes.Mode = CipherMode.ECB;     // No block chaining
aes.Padding = PaddingMode.None; // No padding
using var encryptor = aes.CreateEncryptor();
var ciphertext = encryptor.TransformFinalBlock(parsed.Data, 0, parsed.Data.Length);
Console.WriteLine("{0} expected={1}", ciphertext.SequenceEqual(parsed.Encrypted) ? "OK" : "ERR", BitConverter.ToString(ciphertext));

return;

Parsed ParseData(string[] contents) 
{
    var data = new List<byte>();
    var key = new List<byte>();
    var encrypted = new List<byte>();
    foreach (var line in contents)
    {
        if (line == "key:")
            state = State.Key;
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
                case State.Data:
                    ParseHex(line, data);
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
        Data = data.ToArray(),
        Key = key.ToArray(),
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
    Data,
    Encrypted
}

internal struct Parsed
{
    internal byte[] Key;
    internal byte[] Data;
    internal byte[] Encrypted;
}
