using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;

namespace SvdParser;

public struct AddressBlock
{
    [XmlElement("offset")] public HexUInt Offset;
    [XmlElement("size")] public HexUInt Size;
}
public struct Peripheral
{
    [XmlElement("name")] public string Name;
    [XmlElement("description")] public string Description;
    [XmlElement("baseAddress")] public HexUInt BaseAddress;
    [XmlElement("addressBlock")] public AddressBlock Addresses;
    [XmlElement("registers")] public RegisterList? Registers;
}

public struct RegisterList
{
    [XmlElement("register")] public Register[] Registers;
}

public struct Register
{
    [XmlElement("name")] public string Name;
    [XmlElement("description")] public string Description;
    [XmlElement("addressOffset")] public HexUInt AddressOffset;
    [XmlElement("size")] public HexUInt Size;
    [XmlElement("access")] public string Access;
    [XmlElement("resetValue")] public HexUInt ResetValue;
    [XmlElement("fields")] public FieldList? Fields;
}

public struct Field
{
    [XmlElement("name")] public string Name;
    [XmlElement("description")] public string Description;
    [XmlElement("bitOffset")] public uint BitOffset;
    [XmlElement("bitWidth")] public uint BitWidth;
    [XmlElement("access")] public string Access;
    [XmlElement("enumeratedValues")] public EnumeratedValuesList? EnumeratedValues;
}

public struct EnumeratedValue
{
    [XmlElement("name")] public string Name;
    [XmlElement("description")] public string Description;
    [XmlElement("value")] public HexUInt Value;
}

public struct EnumeratedValuesList
{
    [XmlElement("enumeratedValue")] public EnumeratedValue[] EnumeratedValues;
}

public struct FieldList
{
    [XmlElement("field")] public Field[] Fields;
}

public struct PeripheralList
{
    [XmlElement("peripheral")] public Peripheral[] Peripherals;
}

[XmlRoot("device")]
public struct Device
{
    [XmlElement("name")] public string Name;
    [XmlElement("peripherals")] public PeripheralList Peripherals;
}

public sealed class Parser
{
    public Device DeviceDescription { get; private set; }

    public Parser(string fileName)
    {
        var xmlSerializer = new XmlSerializer(typeof(Device));
        using var fileStream = File.OpenRead(fileName);
        DeviceDescription = (Device)(xmlSerializer.Deserialize(fileStream) ?? throw new ArgumentException("Failed to parse SVD file"));
    }
}

public sealed class HexUInt : IXmlSerializable
{
    public uint Value { get; private set; }
 
    public XmlSchema? GetSchema() => null;
 
    public void ReadXml(XmlReader reader)
    {
        var s = reader.ReadElementContentAsString();
        if (s.StartsWith('#'))
        {
            s = s.Replace("#", "");
            s = s.Replace("x", "");
            Value = Convert.ToUInt32(s, 16);
        }
        else if (s.StartsWith("0x") || s.StartsWith("0X"))
            Value = Convert.ToUInt32(s, 16);
        else
            Value = Convert.ToUInt32(s, 10);
    }
 
    public void WriteXml(XmlWriter writer) => throw new NotImplementedException();
 }

