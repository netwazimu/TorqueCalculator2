import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var massTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Torque App Ready"
        massTextField.placeholder = "Enter mass (kg)"
    }
}
