import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputEmailTextBox: UITextField!
    @IBOutlet weak var inputPasswordTextBox: UITextField!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil {
            goToAdminMainView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        handleLogin()
    }
    
    func handleLogin() {
        let email = inputEmailTextBox.text
        let password = inputPasswordTextBox.text
        guard email != "" , password != "" else {
            print("Form is not valid")
            self.alertUser(title: "Form is not vaild", message: "Please try again")
            return
        }
        fetchUser()
    }
    
    func fetchUser() {
        let referance = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
        let email = inputEmailTextBox.text
        let password = inputPasswordTextBox.text
        referance.child("admins").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of:.childAdded, with:{ (snapshot) in
            // Get user value
            if let users = snapshot.value as? Dictionary <String,String>{
                if (users["email"]!.isEqual(email)) || (users["password"]!.isEqual(password)) {
                    print("email : \(users["email"]!)")
                    print("name : \(users["password"]!)")
                    //sign in account
                    FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
                        if error != nil{
                            print("Sign in error - code:\(error)")
                            self.alertUser(title: "Error", message: "Please try again")
                        } else {
                            self.appDelegate.currentUser = FIRAuth.auth()?.currentUser
                            self.appDelegate.myEmail = self.appDelegate.currentUser?.email
                            self.appDelegate.myUID = self.appDelegate.currentUser?.uid
                            self.goToAdminMainView()
                        }
                    })
                }
            }
        })
    }
    
    func alertUser(title:String , message:String) -> Void {
        let messageWindows = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "done", style: .cancel, handler: nil)
        messageWindows.addAction(action)
        self.present(messageWindows, animated: true, completion: nil)
    }
    
    func goToAdminMainView() {
        let tabBarPage = self.storyboard?.instantiateViewController(withIdentifier: "tabBarPage") as! TabBarC
        self.present(tabBarPage, animated: false, completion: nil)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            if textField == inputEmailTextBox {
                inputPasswordTextBox.becomeFirstResponder()
            } else if textField == inputPasswordTextBox {
                inputPasswordTextBox.resignFirstResponder()
                handleLogin()
            }
            return false
        }
        return true
    }

}
