//
//  Brain.swift
//  Calculator
//
//  Created by Benjamin Herzog on 18.08.17.
//  Copyright © 2017 Benjamin Herzog. All rights reserved.
//

import ParserCombinator

struct TestError: ParseError {
    let code: UInt64
    
    init(_ code: UInt64) {
        self.code = code
    }
}

enum Brain {
    
    private static func string(_ s: String) -> Parser<String, String> {
        return Parser { str in
            guard str.hasPrefix(s) else {
                return .fail(TestError(1))
            }
            return .success(result: s, rest: String(str.dropFirst(s.count)))
        }
    }
    
    private static let number = "-?[0-9]+(\\.[0-9]+)?".r ^^ { Double($0.map(String.init).joined()) ?? 0 }
    
    private static let foundationFunctions: [Parser<String, Double>] = [
        ("sin", sin),
        ("sqrt", sqrt),
        ("tan", tan)
    ].map({ name, f in (string("\(name)(") >~ expr <~ string(")")) ^^ f })
    
    private static let funcCall = Parser.or(foundationFunctions)
    
    private static let factor: Parser<String, Double> = funcCall | number | string("(") >~ expr <~ string(")")
    
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
    
    static func compute(input: String) -> Double {
        return expr.parse(input) ?? 0.0
    }
    
}
