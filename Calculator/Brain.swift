//
//  Brain.swift
//  Calculator
//
//  Created by Benjamin Herzog on 18.08.17.
//  Copyright © 2017 Benjamin Herzog. All rights reserved.
//

import ParserCombinator

enum Brain {
    
    enum Error: ParseError, CustomStringConvertible {
        case expected(String, got: String)
        
        var code: UInt64 {
            switch self {
            case .expected(_): return 0
            }
        }
        
        var description: String {
            switch self {
            case let .expected(e, got):
                return "Expected \(e), but got \(got) instead."
            }
        }
    }
    
    private static func string(_ s: String) -> Parser<String, String> {
        return Parser { str in
            guard str.hasPrefix(s) else {
                return .fail(Error.expected(s, got: String(str.prefix(s.count))))
            }
            return .success(result: s, rest: String(str.dropFirst(s.count)))
        }
    }
    
    private static let number = "-?[0-9]+(\\.[0-9]+)?".r ^^ { Double($0.map(String.init).joined()) ?? 0 }
    
    private static let foundationFunctions: [Parser<String, Double>] = {
        let functions: [(String, (Double) -> Double)] = [
            ("asin", asin),
            ("acos", acos),
            ("atan", atan),
            ("ceil", ceil),
            ("cos", cos),
            ("cosh", cosh),
            ("fabs", fabs),
            ("floor", floor),
            ("log", log),
            ("log2", log2),
            ("log10", log10),
            ("round", round),
            ("sin", sin),
            ("sinh", sinh),
            ("sqrt", sqrt),
            ("tan", tan)
        ]
        return functions.map({ name, f in (string("\(name)(") >~ expr <~ string(")")) ^^ f })
    }()
    
    private static let funcCall = Parser.or(foundationFunctions)
    
    private static let factor = number | string("(") >~ expr <~ string(")") | funcCall
    
    private static let term: Parser<String, Double> = (factor ~ ((string("*") ~ factor) | (string("/") ~ factor)).rep) ^^ {
            number, list in
            return list.reduce(number) { x, op in
                switch op.0 {
                case "*": return x * op.1
                case "/": return x / op.1
                default: fatalError("Expected * or / but got \(op.0)")
                }
            }
        }
    
    private static let expr: Parser<String, Double> = (term ~ ((string("+") ~ term) | (string("-") ~ term)).rep) ^^ {
            number, list in
            return list.reduce(number) { x, op in
                switch op.0 {
                case "+": return x + op.1
                case "-": return x - op.1
                default: fatalError("Expected + or - but got \(op.0)")
                }
            }
        }
    
    static func compute(input: String) -> String {
        switch expr.parse(input) {
        case let .success(result, _):
            return result.description
        case let .fail(err as Error):
            return err.description
        default:
            return "Unexpected error…"
        }
    }
    
}
