import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Just to confirm it works
        titleLabel.text = "Torque App Ready"
    }
}


