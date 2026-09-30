var lines = File.ReadAllLines(args[0]);
var start = false;
var fields = new List<string>();
var structNames = new HashSet<string>{"uint32_t"};

foreach (var line in lines)
{
    if (line.StartsWith("typedef struct"))
    {
        start = true;
        continue;
    }
    if (start && line.StartsWith('}'))
    {
        BuildZigStruct(line);
        fields.Clear();
        start = false;
        continue;
    }
    
    if (start)
        fields.Add(line);
}

return;

void BuildZigStruct(string endLine)
{
    var parts = endLine.Split(' ', ';');
    var structName = parts[1];
    structNames.Add(structName);
    Console.WriteLine("pub const {0} = extern struct {{", structName.ToLower());
    foreach (var field in fields)
        BuildZigField(field);
    Console.WriteLine("};");
}

void BuildZigField(string field)
{
    var parts = field.Split([' ', ';'], StringSplitOptions.RemoveEmptyEntries);
    var dataTypes = parts.Intersect(structNames).ToList();
    if (dataTypes.Count != 1)
        return;
    var dataTypeIndex = parts.IndexOf(dataTypes[0]);
    if (dataTypeIndex == -1)
        return;
    var dataType = dataTypes[0].Replace("uint32_t", "u32").ToLower();
    var fieldName = parts[dataTypeIndex + 1].ToLower();
    var parts2 = fieldName.Split('[');
    if (parts2.Length == 1)
        Console.WriteLine("    {0}: {1},", fieldName, dataType);
    else
    {
        Console.WriteLine("    {1}: [{0}{2},", parts2[1], parts2[0], dataType);
    }
}
