
import UIKit

enum SleepPickerTag: Int {
    case StartTimePicker1 = 1
    case EndTimePicker2
}

class CustomAlertViewController : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    let transitioner = CAVTransitioner()
    var settingDelegate: SettingViewDelegate?
    
    var startTimeStr: String = ""
    var endTimeStr: String = ""
    
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
        
        startTimePicker.tag = SleepPickerTag.StartTimePicker1.rawValue
        endTimePicker.tag = SleepPickerTag.EndTimePicker2.rawValue
        
        startTimePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        
        
        
        titleLabel.text = PropertyUtils.readLocalizedProperty("Setting Sleep Time")
        cancelBtn.setTitle(PropertyUtils.readLocalizedProperty("Cancel"), for: .normal)
        doneBtn.setTitle(PropertyUtils.readLocalizedProperty("Submit"), for: .normal)
        
        startLabel.text = PropertyUtils.readLocalizedProperty("Start Time")
        endLabel.text = PropertyUtils.readLocalizedProperty("End Time")
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //doneBtn.isEnabled = false
        doneBtn.isEnabled = true
        
        var componenets = Calendar.current.dateComponents([.hour, .minute], from: startTimePicker.date)
        if let hour = componenets.hour, let minute = componenets.minute {
            self.startTimeStr = String(format: "%02i:%02i", hour, minute)
        }
        
        componenets = Calendar.current.dateComponents([.hour, .minute], from: endTimePicker.date)
        if let hour = componenets.hour, let minute = componenets.minute {
            self.endTimeStr = String(format: "%02i:%02i", hour, minute)
        }
    }
    
    
    
    func startDateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        if let hour = componenets.hour, let minute = componenets.minute {
            
            self.startTimeStr = String(format: "%02i:%02i", hour, minute)
            
            if self.startTimeStr == "" && self.endTimeStr == "" {
                doneBtn.isEnabled = false
            }
            
        }
    }
    
    func endDateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        if let hour = componenets.hour, let minute = componenets.minute {
            
            self.endTimeStr = String(format: "%02i:%02i", hour, minute)
            
            if self.startTimeStr == "" && self.endTimeStr == "" {
                doneBtn.isEnabled = false
            }
            
        }
    }
    
    /*
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let tag = ActionSheetTag(rawValue: actionSheet.tag) {
            switch tag {
            case .ActionSheet1:
                self.choiceLabel.text = "Button \(buttonIndex) of Action Sheet 1 was selected."
            case .ActionSheet2:
                self.choiceLabel.text = "Button \(buttonIndex) of Action Sheet 2 was selected."
            default:
                println("Unknown action sheet.")
            }
        }
    }
    */
    
    @IBAction func donePressAction(_ sender: UIButton) {
        // format date
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .medium
        //dateFormatter.timeStyle = .none
        
        //startTimePicker.datePickerMode = .time
        //endTimePicker.datePickerMode = .time
        
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        print(dateFormatter.string(from: startTimePicker.date))
        let startTimeStr: String = dateFormatter.string(from: startTimePicker.date)
        
        print(dateFormatter.string(from: endTimePicker.date))
        let endTimeStr: String = dateFormatter.string(from: endTimePicker.date)
        */
        
        let sleepTimeStr = "\(startTimeStr)~\(endTimeStr)"
        
        print("sleepTime=\(sleepTimeStr)")
        settingDelegate?.updateSettingTableView(sleepTime: sleepTimeStr)
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func doDismiss(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
