
import UIKit

class CustomBirthdayAlertVC : UIViewController {
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    let transitioner = CAVTransitioner()

    var settingDelegate: SettingViewDelegate?
    
    var birthdayStr: String = ""
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format for picker
        birthdayPicker.datePickerMode = .date
        
        birthdayPicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        birthdayPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        //birthdayPicker.maximumDate = Date()
        
        birthdayPicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        
        titleLabel.text = PropertyUtils.readLocalizedProperty("Setting Birthday")
        
        
        cancelBtn.setTitle(PropertyUtils.readLocalizedProperty("Cancel"), for: .normal)
        doneButton.setTitle(PropertyUtils.readLocalizedProperty("Submit"), for: .normal)
        
        
        
        // toolbar
        //let toolbar = UIToolbar()
        //toolbar.sizeToFit()
        
        // bar button item
        //let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        //toolbar.setItems([doneButton], animated: false)
        
        //datePickerTxt.inputAccessoryView = toolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doneButton.isEnabled = false
        
    }
    
    
    func dateChanged(_ sender: UIDatePicker) {
        
        
        
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            
            self.birthdayStr = String(format: "%04i-%02i-%02i", year, month, day)
            if self.birthdayStr != "" {
                doneButton.isEnabled = true
            }
        }
    }
    
    /*
    func handler(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        print(dateFormatter.string(from: birthdayPicker.date))
        
        self.birthdayStr = dateFormatter.string(from: birthdayPicker.date)
        
        print("birthdayStr=\(self.birthdayStr)")
    }
    */
    
    @IBAction func doDismiss(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func donePressAction(_ sender: UIButton) {
        // format date
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .medium
        //dateFormatter.timeStyle = .none
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        print(dateFormatter.string(from: birthdayPicker.date))
        
        let birthday: String = dateFormatter.string(from: birthdayPicker.date)
        //self.plistManager.setCellContent(key: "birthday", value: birthday)
        */
        if self.birthdayStr == "" {
            return
        }
        print("birthdayStr=\(self.birthdayStr)")
        settingDelegate?.updateSettingTableView(birthday: self.birthdayStr)
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    /*
    func donePressed() {
        
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        print(dateFormatter.string(from: birthdayPicker.date))
        //self.view.endEditing(true)
    }
    */
}
