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
$BS ⊸ $BB ; $BS ⊕ $BB
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
        fn $Vt ($Bf) : $TT {; $Ss ;} ⊕\
        struct $Vt {; $Bs ;}
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

func randomChoice<T>(_ list: [T]) -> T {
    return list.randomElement()!
}
func randomVariableName() -> String {
    let length = Int.random(in: 1...8)  // Random length between 1 and 8
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let digits = "0123456789"
    let allChars = letters + digits + "_"

    let firstChar = letters.randomElement() ?? "_"
    let rest = (1..<length).map { _ in allChars.randomElement() ?? "_" }

    return String([firstChar] + rest)
}
func randomInt() -> String {
    return String(Int.random(in: -100...100))
}
func randomFloat() -> String {
    return String(Float.random(in: -100...100))
}
func randomString() -> String {
    let notQuote =
        " !#%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    let notBackslash = notQuote  // same set, because both exclude '\' and '"'
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

typealias StringProducer = () -> String
let ε = ""
@MainActor let resolver: [String: StringProducer] = [
    "$BB": { "$LV : $TT" },
    "$Bf": { randomChoice(["$BF", ε]) },
    "$BF": { randomChoice(["$BB,$BF", "$BB"]) },
    "$Bs": { randomChoice(["$BS", ε]) },
    "$BS": { randomChoice(["$BB;$BS", "$BB"]) },
    "$LV": { randomChoice(["$Vt", "$Vt [$Vs]"]) },
    "$Vs": { randomChoice(["$VS", ε]) },
    "$VS": { randomChoice(["$Vt,$VS", "$Vt"]) },
    "$EE": {
        randomChoice([
            "$It", "$Ft", "true", "false", "$Vt", "void", "[$Es]", "$Vt {$Es}", "($EE)", "$EE.$Vt",
            "$EE[$Es]", "$Vt($Es)",
        ])
    },
    "$Es": { randomChoice(["$ES", ε]) },
    "$ES": { randomChoice(["$EE,$ES", "$EE"]) },
    "$CC": {
        randomChoice([
            "read image $Se to $LV", "write image $EE to $Se", "let $LV = $EE", "assert $EE, $Se",
            "print $Se", "show $EE", "time $CC", "fn $Vt ($Bf) : $TT {;$Ss;}", "struct $Vt {;$Bs;}",
        ])
    },
    "$Ss": { randomChoice(["$SS", ε]) },
    "$SS": { randomChoice(["$SC;$SS", "$SC"]) },
    "$TT": { randomChoice(["int", "bool", "float", "$AT", "$Vt", "void"]) },
    "$AT": { randomChoice(["$TT[$CS]", "$TT[]"]) },
    "$Ct": { randomChoice([",$Ct", ε]) },
    "$SC": { randomChoice(["let $LV = $EE", "assert $EE, $Se", "return $EE"]) },
    "$VV": { randomChoice(["int", "bool", "float", "$AT", "$Vt", "void"]) },
    "$CS": { randomChoice(["$Ct", ε]) },
    "$Vt": { randomVariableName() },
    "$It": { randomInt() },
    "$Ft": { randomFloat() },
    "$Se": { randomString() },
]
//the regex for finding unresolved commands is \$\w\w
let regex = try! NSRegularExpression(pattern: "\\$\\w\\w")

@MainActor func createNCommands(n: Int) -> String {
    var bigstring = String(repeating: "$CC;", count: n)
    while true {
        let range = NSRange(location: 0, length: bigstring.utf16.count)
        let match = regex.firstMatch(in: bigstring, options: [], range: range)
        if match == nil {
            break
        }
        let start = bigstring.index(bigstring.startIndex, offsetBy: match!.range.location)
        let end = bigstring.index(start, offsetBy: match!.range.length)
        let key = String(bigstring[start..<end])
        switch resolver[key] {
        case .none:
            fatalError("unresolved key: \(key)")
        case .some(let producer):
            let replacement = producer()
            bigstring.replaceSubrange(start..<end, with: replacement)
        }
    }
    bigstring.replace(";", with: "\n")
    return bigstring
}
