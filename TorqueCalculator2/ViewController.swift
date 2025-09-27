//
//  ViewController.swift
//  TorqueCalculator2
//
//  Created by Brian Omondi on 27/09/2025.
//

import UIKit

class ViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var resultValueLabel: UILabel!

    // MARK: Constants
    private let gravity: Double = 9.81

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Defensive: if outlets are not connected, avoid crash and log helpful message.
        if modeSegmentedControl == nil || massTextField == nil || distanceTextField == nil || calculateButton == nil || resultTitleLabel == nil || resultValueLabel == nil {
            // Outlets not connected - log and return so app doesn't crash
            print("⚠️ One or more IBOutlets are not connected in Main.storyboard.")
            return
        }

        setupUI()
    }

    // MARK: UI Setup
    private func setupUI() {
        // segmented control
        modeSegmentedControl.removeAllSegments()
        modeSegmentedControl.insertSegment(withTitle: "Torque ⇐ Mass", at: 0, animated: false)
        modeSegmentedControl.insertSegment(withTitle: "Mass ⇐ Torque", at: 1, animated: false)
        modeSegmentedControl.selectedSegmentIndex = 0

        // keyboard types
        massTextField.keyboardType = .decimalPad
        distanceTextField.keyboardType = .decimalPad

        // placeholders
        massTextField.placeholder = "e.g. 5.0"
        distanceTextField.placeholder = "e.g. 0.2"

        // button styling
        calculateButton.layer.cornerRadius = 8
        calculateButton.backgroundColor = .systemBlue
        calculateButton.setTitleColor(.white, for: .normal)

        // initial result
        resultTitleLabel.text = "Torque (Nm)"
        resultValueLabel.text = "—"

        addKeyboardAccessory()
    }

    // MARK: Keyboard accessory
    private func addKeyboardAccessory() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexible, done]
        massTextField.inputAccessoryView = toolbar
        distanceTextField.inputAccessoryView = toolbar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: Actions
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        // update labels and placeholders depending on mode
        if sender.selectedSegmentIndex == 0 {
            resultTitleLabel.text = "Torque (Nm)"
            massTextField.placeholder = "e.g. 5.0"
            distanceTextField.placeholder = "e.g. 0.2"
        } else {
            resultTitleLabel.text = "Mass (kg)"
            massTextField.placeholder = "e.g. 10.0"
            distanceTextField.placeholder = "e.g. 0.2"
        }
        resultValueLabel.text = "—"
    }

    @IBAction func calculateTapped(_ sender: UIButton) {
        dismissKeyboard()

        // Read and sanitize inputs
        let rawMassOrTorque = massTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rawDistance = distanceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !rawMassOrTorque.isEmpty, !rawDistance.isEmpty else {
            showAlert(title: "Missing input", message: "Please enter both values.")
            return
        }

        // Replace comma with dot to support locales
        let primarySanitized = rawMassOrTorque.replacingOccurrences(of: ",", with: ".")
        let distanceSanitized = rawDistance.replacingOccurrences(of: ",", with: ".")

        guard let primaryValue = Double(primarySanitized) else {
            showAlert(title: "Invalid number", message: "Please enter a valid number for the first field.")
            return
        }

        guard let distanceValue = Double(distanceSanitized) else {
            showAlert(title: "Invalid distance", message: "Please enter a valid number for distance.")
            return
        }

        if distanceValue == 0 {
            showAlert(title: "Invalid distance", message: "Distance must be non-zero.")
            return
        }

        if modeSegmentedControl.selectedSegmentIndex == 0 {
            // Torque = mass * g * distance
            let mass = primaryValue
            if mass < 0 {
                showAlert(title: "Invalid mass", message: "Mass must be non-negative.")
                return
            }
            let torque = mass * gravity * distanceValue
            resultValueLabel.text = formatted(value: torque) + " Nm"
        } else {
            // Mass = torque / (g * distance)
            let torque = primaryValue
            if torque < 0 {
                showAlert(title: "Invalid torque", message: "Torque must be non-negative.")
                return
            }
            let mass = torque / (gravity * distanceValue)
            resultValueLabel.text = formatted(value: mass) + " kg"
        }
    }

    // MARK: Helpers
    private func formatted(value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 0
        return fmt.string(from: NSNumber(value: value)) ?? String(value)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(a, animated: true, completion: nil)
    }
}
