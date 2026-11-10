foreach (var name in File.ReadAllLines(args[0])
            .Where(line => line.Contains(".word") && line.Contains("_IRQHandler"))
            .Select(line => line.Split('\t')[2]))
{
    Console.WriteLine($"\t.weak\t{name}");
    Console.WriteLine($"\t.thumb_set {name},Default_Handler");
    Console.WriteLine();
}