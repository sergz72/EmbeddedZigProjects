using System.Text.Json;

namespace SvdParser;

public static class ZigStructCreator
{
    private static int _reservedIdx;

    private static string BuildReserved(uint resetValue, uint bitOffset, uint w, bool rw)
    {
        var i = rw ? BuildInitValue(resetValue, bitOffset, w, false) : "";
        var result = $"    reserved{_reservedIdx}: u{w}{i},";
        _reservedIdx++;
        return result;
    }

    private static string ToCamelCasePart(string n)
    {
        if (n.Length > 1)
            return n[0] + n[1..].ToLower();
        return n;
    }
    
    private static string ToCamelCase(string s)
    {
        return s.Split('_').Select(ToCamelCasePart).Aggregate((a, b) => a + b);
    }

    public static List<string> CreateStruct(Peripheral peripheral)
    {
        var lines = new List<string>();
        lines.Add($"const {peripheral.Name.ToUpper()}_BASE = 0x{peripheral.BaseAddress.Value:X};");
        lines.Add("");
        foreach (var cluster in peripheral.Registers?.Clusters ?? Enumerable.Empty<Cluster>())
        {
            CreateStruct(cluster, lines);
            foreach (var cluster2 in cluster.Clusters ?? Enumerable.Empty<Cluster>())
                CreateStruct(cluster2, lines);
        }
        CreateStruct(peripheral, lines);
        if (peripheral.Addresses.Size != null)
            AddInstance(lines, ToCamelCase(peripheral.Name), peripheral.Addresses.Size.Value);
        return lines;
    }

    private static string BuildRegisterName(string peripheralName, string registerName)
    {
        if (registerName.Contains(peripheralName, StringComparison.OrdinalIgnoreCase))
            return ToCamelCase(registerName);
        return peripheralName + ToCamelCase(registerName);
    }
    
    private static void CreateStruct(IPeripheral peripheral, List<string> lines)
    {
        if (peripheral.GetRegisters() == null)
            return;
        var peripheralLines = new List<string>();
        var pname = ToCamelCase(peripheral.GetName());
        peripheralLines.Add($"pub const {pname} = extern struct {{");
        uint offset = 0;
        var resIdx = 0;
        foreach (var register in peripheral.GetRegisters()!.OrderBy(r => r.AddressOffset.Value))
        {
            var regLines = new List<string>();
            var rw = register.Access != "read-only";
            var rName = BuildRegisterName(pname, register.Name);
            var pfName = register.Name.Contains('_') ? register.Name.Split('_')[1].ToLower() : register.Name.ToLower();
            var diff = register.AddressOffset.Value - offset; 
            if (diff != 0)
            {
                peripheralLines.Add($"    reserved{resIdx}: [{diff}]u8,");
                resIdx++;
            }

            var size = register.Size?.Value ?? 32;
            offset = register.AddressOffset.Value + size / 8;
            peripheralLines.Add($"    {pfName}: {rName},");
            regLines.Add($"pub const {rName} = bitpack struct(u{size}) {{");
            uint nextBit = 0;
            _reservedIdx = 0;
            var resetValue  = register.ResetValue?.Value ?? 0;
            if (register.Fields != null && register.Fields.Value.Fields != null)
            {
                foreach (var field in register.Fields.Value.Fields.OrderBy(a => a.BitOffset))
                {
                    var fname = field.Name.ToLower();
                    if (field.BitOffset > nextBit)
                        regLines.Add(BuildReserved(resetValue, field.BitOffset, field.BitOffset - nextBit, rw));

                    if (field.BitWidth == 1)
                    {
                        var iv = rw
                            ? BuildInitValue(resetValue, field.BitOffset, field.BitWidth, true)
                            : "";
                        regLines.Add($"    {fname}: bool{iv},");
                    }
                    else
                    {
                        var v = BuildFieldStruct(pname, lines, field, resetValue, rw);
                        regLines.Add($"    {fname}: {v},");
                    }

                    nextBit = field.BitOffset + field.BitWidth;
                }
            }
            if (nextBit < size)
                regLines.Add(BuildReserved(resetValue, nextBit, size - nextBit, rw));
            regLines.Add("};");
            regLines.Add("");
            lines.AddRange(regLines);
        }
        lines.AddRange(peripheralLines);
        lines.Add("};");
        lines.Add("");
    }

    private static string BuildFieldStruct(string peripheralName, List<string> lines, Field field, uint resetValue, bool rw)
    {
        if (field.EnumeratedValues == null)
        {
            var iv = rw ? BuildInitValue(resetValue, field.BitOffset, field.BitWidth, true) : "";
            return $"u{field.BitWidth}{iv}";
        }
        var sname = BuildRegisterName(peripheralName, field.Name);
        var value = BuildInitValue(resetValue, field.BitOffset, field.BitWidth);
        lines.Add($"pub const {sname} = enum(u{field.BitWidth}) {{");
        var initName = "Unknown";
        foreach (var v in field.EnumeratedValues?.EnumeratedValues ?? Enumerable.Empty<EnumeratedValue>())
        {
            var name = v.Name.Replace("-", "_");
            if (char.IsDigit(name[0]))
                name = "_" + name;
            if (v.Value != null)
            {
                lines.Add($"    {name} = {v.Value.Value},");
                if (v.Value.Value == value)
                    initName = name;
            }
            else
            {
                lines.Add($"    {name},");
            }
        }
        lines.Add("};");
        lines.Add("");
        return $"{sname} = .{initName}";
    }
    
    private static void AddInstance(List<string> lines, string peripheralName, uint size)
    {
        var sz = "0x" + size.ToString("X");
        lines.Add($"pub const {peripheralName.ToLower()}: *volatile {peripheralName} = @ptrFromInt({peripheralName.ToUpper()}_BASE);");
        lines.Add("");
        lines.Add("test \"sizeof test\" {");
        lines.Add("    const std = @import(\"std\");");
        lines.Add($"    try std.testing.expectEqual({sz}, @sizeOf({peripheralName}));");
        lines.Add("}");
    }

    private static uint BuildInitValue(uint resetValue, uint bitOffset, uint bitWidth)
    {
        var mask = (1u << (int)bitWidth) - 1u;
        return (resetValue >> (int)bitOffset) & mask;
    }
    
    private static string BuildInitValue(uint resetValue, uint bitOffset, uint bitWidth, bool useBool) 
    {
        var value = BuildInitValue(resetValue, bitOffset, bitWidth);
        if (useBool && bitWidth == 1)
        {
            return value != 0 ? " = true" : " = false";
        }
        return $" = {value}";
    }
}

