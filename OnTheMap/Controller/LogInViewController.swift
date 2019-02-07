
import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotificationsObserver()
    }
    
    private func setupUI() {
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        API.postSession(username: emailTF.text!, password: passwordTF.text!) { (errString) in
            guard errString == nil else {
                self.showAlert(title: "Error", message: errString!)
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        }
    }
}
