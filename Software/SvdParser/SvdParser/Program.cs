using SvdParser;

var parser = new Parser(args[0]);

foreach (var peripheral in parser.DeviceDescription.Peripherals.Peripherals)
{
    var lines = ZigStructCreator.CreateStruct(peripheral);
    File.WriteAllLines($"{peripheral.Name.ToLower()}.zig", lines);
}

