//
//  ViewController.swift
//  Calculator
//
//  Created by Benjamin Herzog on 18.08.17.
//  Copyright © 2017 Benjamin Herzog. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var textField: UITextField? {
        didSet {
            self.textField?.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        }
    }
    @IBOutlet private var label: UILabel? {
        didSet {
            self.label?.text = Brain.compute(input: "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField?.becomeFirstResponder()
    }
    
    @objc func textChanged(_ textField: UITextField) {
        let input = textField.text ?? ""
        self.label?.text = Brain.compute(input: input)
    }
    
    @IBAction func helpPressed(_ sender: UIBarButtonItem) {
        let functions = Brain.availableFormulas().joined(separator: ", ")
        let message = """
Welcome at Calculator! The app was written as a small example of Parsel, a parser combinator library written in Swift.

You can use it to calculate mathematical computations. Use +, -, /, *, (, ), ^ and one of the following functions: \(functions).
"""
        let alert = UIAlertController(title: "Help", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thanks!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
