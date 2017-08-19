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
    @IBOutlet private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField?.becomeFirstResponder()
    }
    
    @objc func textChanged(_ textField: UITextField) {
        let input = textField.text ?? ""
        self.label?.text = Brain.compute(input: input).description
    }
    
}
