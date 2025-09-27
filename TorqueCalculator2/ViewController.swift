//
//  ViewController.swift
//  TorqueCalculator2
//
//  Created by Brian Omondi on 27/09/2025.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets (connected from Main.storyboard)
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl! // 0 = Torque from Mass, 1 = Mass from Torque
    @IBOutlet weak var primaryTextField: UITextField! // mass or torque depending on mode
    @IBOutlet weak var secondaryTextField: UITextField! // distance
    @IBOutlet weak var primaryLabel: UILabel! // label for primary field
    @IBOutlet weak var secondaryLabel: UILabel! // label for secondary field
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultValueLabel: UILabel!

    // Constants
    private let gravity: Double = 9.81

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLabelsForSelectedMode()
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Appearance
        view.backgroundColor = .systemBackground

        //modeSegmentedControl.removeAllSegments()
        modeSegmentedControl.insertSegment(withTitle: "Torque ⇐ Mass", at: 0, animated: false)
        modeSegmentedControl.insertSegment(withTitle: "Mass ⇐ Torque", at: 1, animated: false)
        modeSegmentedControl.selectedSegmentIndex = 0

        primaryTextField.keyboardType = .decimalPad
        secondaryTextField.keyboardType = .decimalPad

        primaryTextField.placeholder = "Enter value"
        secondaryTextField.placeholder = "Enter distance (m)"

        primaryTextField.delegate = self
        secondaryTextField.delegate = self

        // Button styling
        calculateButton.layer.cornerRadius = 8
        calculateButton.setTitleColor(.white, for: .normal)
        calculateButton.backgroundColor = .systemBlue

        // Initial result
        resultTitleLabel.text = "Result"
        resultValueLabel.text = "—"

        // Keyboard accessory toolbar with Done button
        addKeyboardAccessory()

        // Dismiss keyboard when tapping outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func addKeyboardAccessory() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let done: UIBarButtonItem
        if #available(iOS 16.0, *) {
            done = UIBarButtonItem(title: "Done", style: .prominent, target: self, action: #selector(dismissKeyboard))
        } else {
            done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        }
        toolbar.items = [flexible, done]
        primaryTextField.inputAccessoryView = toolbar
        secondaryTextField.inputAccessoryView = toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions

    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        updateLabelsForSelectedMode()
        clearResult()
        clearInputs()
    }

    @IBAction func calculateTapped(_ sender: UIButton) {
        calculate()
    }

    // MARK: - Calculation Logic

    private func updateLabelsForSelectedMode() {
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            // Torque from Mass
            primaryLabel.text = "Mass (kg)"
            primaryTextField.placeholder = "e.g. 5.0"
            secondaryLabel.text = "Distance (m)"
            secondaryTextField.placeholder = "e.g. 0.2"
            resultTitleLabel.text = "Torque (Nm)"
        } else {
            // Mass from Torque
            primaryLabel.text = "Torque (Nm)"
            primaryTextField.placeholder = "e.g. 10.0"
            secondaryLabel.text = "Distance (m)"
            secondaryTextField.placeholder = "e.g. 0.2"
            resultTitleLabel.text = "Mass (kg)"
        }
    }

    private func clearResult() {
        resultValueLabel.text = "—"
    }

    private func clearInputs() {
        primaryTextField.text = nil
        secondaryTextField.text = nil
    }

    private func calculate() {
        dismissKeyboard()

        // Validate inputs
        guard let primaryText = primaryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !primaryText.isEmpty,
              let secondaryText = secondaryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !secondaryText.isEmpty else {
            showAlert(title: "Missing input", message: "Please enter both values.")
            return
        }

        // Convert to Double safely (supports decimal comma by replacing comma with dot)
        let sanitizedPrimary = primaryText.replacingOccurrences(of: ",", with: ".")
        let sanitizedSecondary = secondaryText.replacingOccurrences(of: ",", with: ".")

        guard let primaryValue = Double(sanitizedPrimary) else {
            showAlert(title: "Invalid input", message: "The first value is not a valid number.")
            return
        }

        guard let distance = Double(sanitizedSecondary) else {
            showAlert(title: "Invalid input", message: "Distance must be a valid number.")
            return
        }

        if distance == 0 {
            showAlert(title: "Invalid distance", message: "Distance must be non-zero.")
            return
        }

        // Perform calculation based on mode
        if modeSegmentedControl.selectedSegmentIndex == 0 {
            // Torque = mass * g * distance
            let mass = primaryValue
            if mass < 0 {
                showAlert(title: "Invalid mass", message: "Mass must be non-negative.")
                return
            }
            let torque = mass * gravity * distance
            resultValueLabel.text = formatNumber(torque) + " Nm"
        } else {
            // Mass = torque / (g * distance)
            let torque = primaryValue
            if torque < 0 {
                showAlert(title: "Invalid torque", message: "Torque must be non-negative.")
                return
            }
            let mass = torque / (gravity * distance)
            resultValueLabel.text = formatNumber(mass) + " kg"
        }
    }

    // MARK: - Helpers

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(a, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Move to next or dismiss
        if textField == primaryTextField {
            secondaryTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
