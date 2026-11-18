if (args.Length != 2)
{
    Console.WriteLine("Usage: HandlerGenerate asm|c file_name");
    return;
}

switch (args[0])
{
    case "asm":
        FromAsm(args[1]);
        break;
    case "c":
        FromC(args[1]);
        break;
    default:
        Console.WriteLine("Unknown format");
        break;
}

return;

void FromAsm(string fileName)
{
    foreach (var name in File.ReadAllLines(fileName)
                 .Where(line => line.Contains(".word") && line.Contains("_IRQHandler"))
                 .Select(line => line.Split('\t')[2]))
    {
        Console.WriteLine($"\t.weak\t{name}");
        Console.WriteLine($"\t.thumb_set {name},Default_Handler");
        Console.WriteLine();
    }
}

void FromC(string fileName)
{
    var names = File.ReadAllLines(fileName)
        .Where(line => line.Contains("= (void*)") && line.Contains("_Handler"))
        .Select(line => line.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)[3])
        .ToList();
    foreach (var name in names)
    {
        Console.WriteLine($"\t.word\t{name}");
    }
    Console.WriteLine();
    Console.WriteLine();

    foreach (var name in names)
    {
        Console.WriteLine($"\t.weak\t{name}");
        Console.WriteLine($"\t.thumb_set {name},Default_Handler");
        Console.WriteLine();
    }
}
