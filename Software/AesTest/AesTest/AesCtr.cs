namespace AesTest;

using System;
using System.Security.Cryptography;

public sealed class AesCtr : IDisposable
{
    private readonly Aes _aes;
    private readonly ICryptoTransform _encryptor;
    private readonly byte[] _counter;
    private readonly byte[] _keystreamBlock = new byte[16];
    private int _keystreamIndex = 16; // Forces block generation on first byte

    public AesCtr(byte[] key, byte[] initialCounter)
    {
        if (key.Length != 16 && key.Length != 24 && key.Length != 32)
            throw new ArgumentException("Key must be 128, 192, or 256 bits.", nameof(key));
        
        if (initialCounter.Length != 16)
            throw new ArgumentException("Initial counter (IV/Nonce) must be 16 bytes (128 bits).", nameof(initialCounter));

        _counter = (byte[])initialCounter.Clone();

        _aes = Aes.Create();
        _aes.Mode = CipherMode.ECB;
        _aes.Padding = PaddingMode.None;

        // IV is ignored in ECB mode, pass a zeroed array
        _encryptor = _aes.CreateEncryptor(key, new byte[16]);
    }

    /// <summary>
    /// Encrypts or decrypts a byte array.
    /// </summary>
    public byte[] Transform(byte[] input)
    {
        var output = new byte[input.Length];
        Transform(input, output);
        return output;
    }

    /// <summary>
    /// Encrypts or decrypts spans in-place or into a destination buffer.
    /// </summary>
    public void Transform(ReadOnlySpan<byte> input, Span<byte> output)
    {
        if (output.Length < input.Length)
            throw new ArgumentException("Output buffer is smaller than input.", nameof(output));

        for (int i = 0; i < input.Length; i++)
        {
            if (_keystreamIndex == 16)
            {
                GenerateNextKeystreamBlock();
                _keystreamIndex = 0;
            }

            output[i] = (byte)(input[i] ^ _keystreamBlock[_keystreamIndex++]);
        }
    }

    private void GenerateNextKeystreamBlock()
    {
        // Encrypt the current counter value to produce the keystream
        _encryptor.TransformBlock(_counter, 0, 16, _keystreamBlock, 0);

        // Increment the 128-bit counter (Big-Endian)
        for (int i = 15; i >= 0; i--)
        {
            if (++_counter[i] != 0)
                break;
        }
    }

    public void Dispose()
    {
        _encryptor.Dispose();
        _aes.Dispose();
        Array.Clear(_counter, 0, _counter.Length);
        Array.Clear(_keystreamBlock, 0, _keystreamBlock.Length);
    }
}
