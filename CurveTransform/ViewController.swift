import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ncd = NotificationCenter.default
        ncd.addObserver(self, selector: keyboardShow, name: UIResponder.keyboardWillShowNotification, object: nil)
        ncd.addObserver(self, selector: keyboardHide, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private let keyboardShow = #selector(handleKeyboardWillShowNotification(_:))
    @objc
    func handleKeyboardWillShowNotification(_ notification: Notification) {
        guard let keyboardNotification = KeyboardNotification(notification) else {
            return
        }
        
        var options: UIView.AnimationOptions = .allowUserInteraction
        options.insertAnimationCurve(keyboardNotification.animationCurve)
        
        UIView.animate(withDuration: keyboardNotification.animationDuration,
                       delay: 0,
                       options: options,
                       animations: {
                        self.textField.transform = CGAffineTransform.init(translationX: 0, y: -keyboardNotification.endFrame.height)
        }, completion: nil)
    }
    
    private let keyboardHide = #selector(handleKeyboardWillHideNotification(_:))
    @objc
    func handleKeyboardWillHideNotification(_ notification: Notification) {
        guard let keyboardNotification = KeyboardNotification(notification) else {
            return
        }
        
        var options: UIView.AnimationOptions = .allowUserInteraction
        options.insertAnimationCurve(keyboardNotification.animationCurve)
        
        UIView.animate(withDuration: keyboardNotification.animationDuration,
                       delay: 0,
                       options: options,
                       animations: {
                        self.textField.transform = .identity
        }, completion: nil)
    }

}

public extension UIView.AnimationOptions {
    // FIXME: This is crashing, because we hand in an invalid animation curve to transform this in
    // an animation option
    public mutating func insertAnimationCurve(_ curve: UIView.AnimationCurve) {
        switch curve {
        case .easeIn:
            self.insert(.curveEaseIn)
        case .easeOut:
            self.insert(.curveEaseOut)
        case .easeInOut:
            self.insert(.curveEaseInOut)
        case .linear:
            self.insert(.curveLinear)
        // FIXME: Workaround is to add a default case that does nothing :/
        //default:
        //   break;
        }
    }
}

struct KeyboardNotification {
    let beginFrame: CGRect
    let endFrame: CGRect
    let animationDuration: Double
    let animationCurve: UIView.AnimationCurve
    let isLocal: Bool
    
    init?(_ notification: Notification) {
        guard [UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification].contains(notification.name) else {
            return nil
        }
        
        let userInforamtion = notification.userInfo!
        
        beginFrame = userInforamtion[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        endFrame = userInforamtion[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        animationDuration = userInforamtion[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        /// FIXME: This is returning 7 instead of an valid animation curve :/ This will be breaking many animations from the keyboard :/
        animationCurve = UIView.AnimationCurve(rawValue: userInforamtion[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        isLocal = userInforamtion[UIResponder.keyboardIsLocalUserInfoKey] as! Bool
    }
}
