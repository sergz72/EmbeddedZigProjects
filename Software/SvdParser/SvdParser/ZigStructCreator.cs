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
    
    private static string ToCamelCase(string s)
    {
        return s.Split('_').Select(n => n[0] + n[1..].ToLower()).Aggregate((a, b) => a + b);
    }

    public static List<string> CreateStruct(Peripheral peripheral)
    {
        var lines = new List<string>();
        lines.Add($"const {peripheral.Name.ToUpper()}_BASE = 0x{peripheral.BaseAddress.Value:X};");
        lines.Add("");
        if (peripheral.Registers == null || peripheral.Registers.Value.Registers == null)
            return lines;
        var peripheralLines = new List<string>();
        peripheralLines.Add($"pub const {peripheral.Name} = extern struct {{");
        uint offset = 0;
        var resIdx = 0;
        foreach (var register in peripheral.Registers.Value.Registers.OrderBy(r => r.AddressOffset.Value))
        {
            var regLines = new List<string>();
            var rw = register.Access != "read-only";
            var rName = ToCamelCase(register.Name);
            var pfName = register.Name.Contains('_') ? register.Name.Split('_')[1].ToLower() : register.Name.ToLower();
            var diff = register.AddressOffset.Value - offset; 
            if (diff != 0)
            {
                peripheralLines.Add($"    reserved{resIdx}: [{diff}]u8,");
                resIdx++;
            }
            offset = register.AddressOffset.Value + register.Size.Value / 8;
            peripheralLines.Add($"    {pfName}: {rName},");
            regLines.Add($"pub const {rName} = packed struct(u{register.Size.Value}) {{");
            uint nextBit = 0;
            _reservedIdx = 0;
            if (register.Fields != null && register.Fields.Value.Fields != null)
            {
                foreach (var field in register.Fields.Value.Fields.OrderBy(a => a.BitOffset))
                {
                    var fname = field.Name.ToLower();
                    if (field.BitOffset > nextBit)
                        regLines.Add(BuildReserved(register.ResetValue.Value, field.BitOffset,
                            field.BitOffset - nextBit, rw));

                    if (field.BitWidth == 1)
                    {
                        var iv = rw
                            ? BuildInitValue(register.ResetValue.Value, field.BitOffset, field.BitWidth, true)
                            : "";
                        regLines.Add($"    {fname}: bool{iv},");
                    }
                    else
                    {
                        var v = BuildFieldStruct(lines, field, register.ResetValue.Value, rw);
                        regLines.Add($"    {fname}: {v},");
                    }

                    nextBit = field.BitOffset + field.BitWidth;
                }
            }
            if (nextBit < register.Size.Value)
                regLines.Add(BuildReserved(register.ResetValue.Value, nextBit, register.Size.Value - nextBit, rw));
            regLines.Add("};");
            regLines.Add("");
            lines.AddRange(regLines);
        }
        lines.AddRange(peripheralLines);
        lines.Add("};");
        lines.Add("");
        AddInstance(lines, peripheral.Name, peripheral.Addresses.Size.Value);
        return lines;
    }

    private static string BuildFieldStruct(List<string> lines, Field field, uint resetValue, bool rw)
    {
        if (field.EnumeratedValues == null)
        {
            var iv = rw ? BuildInitValue(resetValue, field.BitOffset, field.BitWidth, true) : "";
            return $"u{field.BitWidth}{iv}";
        }
        var sname = ToCamelCase(field.Name);
        var value = BuildInitValue(resetValue, field.BitOffset, field.BitWidth);
        lines.Add($"pub const {sname} = enum(u{field.BitWidth}) {{");
        var initName = "Unknown";
        foreach (var v in field.EnumeratedValues?.EnumeratedValues ?? Enumerable.Empty<EnumeratedValue>())
        {
            var name = v.Name.Replace("-", "_");
            if (char.IsDigit(name[0]))
                name = "_" + name;
            lines.Add($"    {name} = {v.Value.Value},");
            if (v.Value.Value == value)
                initName = name;
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
        lines.Add($"    try std.testing.expectEqual({sz}, @sizeOf({peripheralName}));\n");
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

