#if os(macOS)
    import Darwin
#else
    import Glibc
#endif

//get first command line argument
//then make sure its a valid int
guard CommandLine.arguments.count > 1 else {
    print("No input")
    exit(1)
}
guard let cmdCount = Int(CommandLine.arguments[1]) else {
    print("Invalid input")
    exit(1)
}
print(createNCommandsToken(n: cmdCount))
