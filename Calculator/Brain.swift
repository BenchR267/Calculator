//
//  Brain.swift
//  Calculator
//
//  Created by Benjamin Herzog on 18.08.17.
//  Copyright © 2017 Benjamin Herzog. All rights reserved.
//

import Parsel

enum Brain {
    
    enum Error: ParseError, CustomStringConvertible {
        case expected(String, got: String)
        
        var description: String {
            switch self {
            case let .expected(e, got):
                return "Expected \(e), but got \(got) instead."
            }
        }
    }
    
    private static let functions: [(String, (Double) -> Double)] = [
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
    
    private static let foundationFunctions = functions.map({ name, f in L.string("\(name)(") >~ calculator <~ L.string(")") ^^ f })
    
    private static let funcCall = Parser.or(foundationFunctions)
    
    private static let factor = (L.string("(") >~ expr <~ L.string(")")) | funcCall | L.floatingNumber
    
    private static let term: Parser<String, Double> = factor ~ ((L.multiply ~ factor) | (L.divide ~ factor)).rep ^^ {
        number, list in
        return list.reduce(number) { x, op in
            switch op.0 {
            case "*": return x * op.1
            case "/": return x / op.1
            default: fatalError("Expected * or / but got \(op.0)")
            }
        }
    }
    
    private static let expr: Parser<String, Double> = term ~ ((L.plus ~ term) | (L.minus ~ term)).rep ^^ {
        number, list in
        return list.reduce(number) { x, op in
            switch op.0 {
            case "+": return x + op.1
            case "-": return x - op.1
            default: fatalError("Expected + or - but got \(op.0)")
            }
        }
    }
    
    private static let powParser: Parser<String, Double> = expr ~ (L.string("^") ~ expr).rep ^^ {
        number, list in
        return list.reduce(number) { x, op in
            return pow(x, op.1)
        }
    }
    
    private static let calculator = powParser
    
    static func compute(input: String) -> String {
        guard !input.isEmpty else {
            return "Type in some calculation"
        }
        switch calculator.parse(input) {
        case let .success(result, _):
            return result.description
        case let .fail(err as Error):
            return err.description
        default:
            return "Unable to process"
        }
    }
    
    static func availableFormulas() -> [String] {
        return functions.map({ $0.0 })
    }
    
}
