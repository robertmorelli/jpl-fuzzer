/*
 type : int
      | bool
      | float
      | <type> [ , ... ]
      | <variable>
      | void
 cmd  : read image <string> to <lvalue>
      | write image <expr> to <string>
      | let <lvalue> = <expr>
      | assert <expr> , <string>
      | print <string>
      | show <expr>
      | time <cmd>
      | fn <variable> ( <binding> , ... ) : <type> { ;
            <stmt> ; ... ;
        }
      | struct <variable> { ;
            <variable>: <type> ; ... ;
        }
 stmt : let <lvalue> = <expr>
      | assert <expr> , <string>
      | return <expr>
 expr : <integer>
      | <float>
      | true
      | false
      | <variable>
      | void
      | [ <expr> , ... ]
      | <variable> { <expr> , ... }
      | ( <expr> )
      | <expr> . <variable>
      | <expr> [ <expr> , ... ]
      | <variable> ( <expr> , ... )
 lvalue : <variable>
        | <variable> [ <variable> , ... ]
 binding : <lvalue> : <type>

$BB ⊸ $LV : $TT
$Bf ⊸ $BF ⊕ ε
$BF ⊸ $BB,$BF ⊕ $BB
$Bs ⊸ $BS ⊕ ε
$BS ⊸ $Vt : $TT ; $BS ⊕ $Vt : $TT
$LV ⊸ $Vt ⊕ $Vt [$Vs]
$Vs ⊸ $VS ⊕ ε
$VS ⊸ $Vt,$VS ⊕ $Vt
$EE ⊸ $It ⊕ $Ft ⊕ true ⊕ false ⊕ $Vt ⊕ void ⊕\
       [$Es] ⊕ $Vt {$Es} ⊕ ($EE) ⊕ $EE . $Vt ⊕\
       $EE [$Es] ⊕ $Vt ($Es)
$Es ⊸ $ES ⊕ ε
$ES ⊸ $EE,$ES ⊕ $EE
$CC ⊸  read image $Se to $LV ⊕\
        write image $EE to $Se ⊕\
        let $LV = $EE ⊕\
        assert $EE , $Se ⊕\
        print $Se ⊕\
        show $EE ⊕\
        time $CC ⊕\
        fn $Vt ($Bf) : $TT {;$Ss;} ⊕\
        struct $Vt {;$Bs;}
$Ss ⊸ $SS ⊕ ε
$SS ⊸ $SC ; $SS ⊕ $SC
$TT ⊸ int ⊕ bool ⊕ float ⊕ $AT ⊕ $Vt ⊕ void
$AT ⊸ $TT [$CS] ⊕ $TT []
$Ct ⊸ ,$Ct ⊕ ε
$SC ⊸ let $LV = $EE ⊕\
       assert $EE , $Se ⊕\
       return $EE
*/
import Foundation

// MARK: - Helpers

func randomChoice<T>(_ list: [T]) -> T {
    return list.randomElement()!
}
let keywords: Set = [
    "read", "image", "to", "write", "let", "assert", "print", "show", "time", "fn", "struct",
    "int", "bool", "float", "true", "false", "void", "if", "else", "return", "while", "for",
    "break", "continue", "switch", "case", "default", "import", "from", "as", "module", "sum",  //thanks AI
]

func randomVariableName() -> String {
    var attempt = ""
    repeat {
        let length = Int.random(in: 1...8)
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let digits = "0123456789"
        let allChars = letters + digits + "_"
        let firstChar = letters.randomElement() ?? "_"
        let rest = (1..<length).map { _ in allChars.randomElement() ?? "_" }
        attempt = String([firstChar] + rest)
    } while keywords.contains(attempt)
    return attempt
}

func randomInt() -> String {
    return String(Int.random(in: 0...10000))
}

func randomFloat() -> String {
    return String(Float.random(in: 0...10000))
}

func randomString() -> String {
    let notQuote =
        " !#%&'()*+,-./0123456789:<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    let notBackslash = notQuote
    let maxCount = 10
    var result = "\""
    let countNotQuote = Int.random(in: 0...maxCount)
    for _ in 0..<countNotQuote {
        result.append(notQuote.randomElement()!)
    }
    result.append(notBackslash.randomElement()!)
    if Bool.random() && Bool.random() && Bool.random() {
        let pairCount = Int.random(in: 0...maxCount)
        for _ in 0..<pairCount {
            result.append("\\\\")
        }
    }
    result.append("\"")
    return result
}

enum token {
    case variable(variable)
    case terminal(terminal)
    case syntax(String)
    case ε
}

enum terminal {
    case Vt, It, Ft, Se
    func toString() -> String {
        switch self {
        case .Vt: return randomVariableName()
        case .It: return randomInt()
        case .Ft: return randomFloat()
        case .Se: return randomString()
        }
    }
}

enum variable {
    case BB, Bf, BF, Bs, BS, LV, Vs, VS
    case EE, Es, ES, CC, Ss, SS, TT, AT
    case Ct, SC, VV, CS

    func resolve() -> [token] {
        switch self {
        case .BB:
            return [.variable(.LV), .syntax(":"), .variable(.TT)]
        case .Bf:
            return randomChoice([[.variable(.BF)], [.ε]])
        case .BF:
            return randomChoice([
                [.variable(.BB), .syntax(","), .variable(.BF)],
                [.variable(.BB)],
            ])
        case .Bs:
            return randomChoice([[.variable(.BS)], [.ε]])
        case .BS:
            return randomChoice([
                [.terminal(.Vt), .syntax(":"), .variable(.TT), .syntax("\n"), .variable(.BS)],
                [.terminal(.Vt), .syntax(":"), .variable(.TT)],
            ])
        case .LV:
            return randomChoice([
                [.terminal(.Vt)],
                [.terminal(.Vt), .syntax("["), .variable(.Vs), .syntax("]")],
            ])
        case .Vs:
            return randomChoice([[.variable(.VS)], [.ε]])
        case .VS:
            return randomChoice([
                [.terminal(.Vt), .syntax(","), .variable(.VS)],
                [.terminal(.Vt)],
            ])
        case .EE:
            return randomChoice([
                [.terminal(.It)],
                [.terminal(.Ft)],
                [.syntax("true")],
                [.syntax("false")],
                [.terminal(.Vt)],
                [.syntax("void")],
                [.syntax("["), .variable(.Es), .syntax("]")],
                [.terminal(.Vt), .syntax("{"), .variable(.Es), .syntax("}")],
                [.syntax("("), .variable(.EE), .syntax(")")],
                [.variable(.EE), .syntax("."), .terminal(.Vt)],
                [.variable(.EE), .syntax("["), .variable(.Es), .syntax("]")],
                [.terminal(.Vt), .syntax("("), .variable(.Es), .syntax(")")],
            ])
        case .Es:
            return randomChoice([[.variable(.ES)], [.ε]])
        case .ES:
            return randomChoice([
                [.variable(.EE), .syntax(","), .variable(.ES)],
                [.variable(.EE)],
            ])
        case .CC:
            return randomChoice([
                [.syntax("read"), .syntax("image"), .terminal(.Se), .syntax("to"), .variable(.LV)],
                [
                    .syntax("write"), .syntax("image"), .variable(.EE), .syntax("to"),
                    .terminal(.Se),
                ],
                [.syntax("let"), .variable(.LV), .syntax("="), .variable(.EE)],
                [.syntax("assert"), .variable(.EE), .syntax(","), .terminal(.Se)],
                [.syntax("print"), .terminal(.Se)],
                [.syntax("show"), .variable(.EE)],
                [.syntax("time"), .variable(.CC)],
                [
                    .syntax("fn"), .terminal(.Vt), .syntax("("), .variable(.Bf), .syntax(")"),
                    .syntax(":"), .variable(.TT), .syntax("{"), .syntax("\n"), .variable(.Ss),
                    .syntax("\n"), .syntax("}"),
                ],
                [
                    .syntax("struct"), .terminal(.Vt), .syntax("{"), .syntax("\n"),
                    .variable(.Bs), .syntax("\n"), .syntax("}"),
                ],
            ])
        case .Ss:
            return randomChoice([[.variable(.SS)], [.ε]])
        case .SS:
            return randomChoice([
                [.variable(.SC), .syntax("\n"), .variable(.SS)],
                [.variable(.SC)],
            ])
        case .TT:
            return randomChoice([
                [.syntax("int")],
                [.syntax("bool")],
                [.syntax("float")],
                [.variable(.AT)],
                [.terminal(.Vt)],
                [.syntax("void")],
            ])
        case .AT:
            return randomChoice([
                [.variable(.TT), .syntax("["), .variable(.CS), .syntax("]")],
                [.variable(.TT), .syntax("[]")],
            ])
        case .Ct:
            return randomChoice([
                [.syntax(","), .variable(.Ct)],
                [.ε],
            ])
        case .SC:
            return randomChoice([
                [.syntax("let"), .variable(.LV), .syntax("="), .variable(.EE)],
                [.syntax("assert"), .variable(.EE), .syntax(","), .terminal(.Se)],
                [.syntax("return"), .variable(.EE)],
            ])
        case .VV:
            return randomChoice([
                [.syntax("int")],
                [.syntax("bool")],
                [.syntax("float")],
                [.variable(.AT)],
                [.terminal(.Vt)],
                [.syntax("void")],
            ])
        case .CS:
            return randomChoice([
                [.variable(.Ct)],
                [.ε],
            ])
        }
    }
}

func expandToken(_ tok: token) -> [token] {
    switch tok {
    case .ε:
        return []
    case .terminal(_), .syntax(_):
        return [tok]
    case .variable(let v):
        let expansion = v.resolve()
        var result: [token] = []
        for subtoken in expansion {
            result.append(contentsOf: expandToken(subtoken))
        }
        return result
    }
}

extension token {
    func toString() -> String {
        switch self {
        case .terminal(let t):
            return t.toString()
        case .syntax(let s):
            return s
        case .variable(_):
            return ""
        case .ε:
            return ""
        }
    }
}

func createNCommandsToken(n: Int) async -> String {
    var commands = Array(repeating: "", count: n)
    await withTaskGroup(of: (Int, String).self) { group in
        for index in 0..<n {
            group.addTask {
                let tokens = expandToken(.variable(.CC))
                let command = tokens.map { $0.toString() }.joined(separator: " ")
                return (index, command)
            }
        }
        for await (index, command) in group {
            commands[index] = command
        }
    }
    return commands.joined(separator: "\n")
}
