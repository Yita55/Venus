
import UIKit

class CustomStepGoalAlertVC : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var stepGoalPicker: UIPickerView!
    
    let transitioner = CAVTransitioner()
    
    var plistManager = PlistManager()

    var settingDelegate: SettingViewDelegate?
    
    var goalArray = [String]()
    
    var selectItem: String = ""
    
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
        //身高：61cm~241cm (參考 moto)
        //體重：3kg~120kg (參考小米)
        // 1~999999
        let first = 100
        let last = 999999
        let interval = 100
        //var n = 0
        goalArray.append("1")
        for f in stride(from: first, through: last, by: interval) {
            //print(f)
            //n += 1
            let item: String = "\(f)"
            goalArray.append(item)
        }
        /*
        for i in 1..<999999 {
            let item: String = "\(i)"
            goalArray.append(item)
        }
        */
        stepGoalPicker.delegate = self
        stepGoalPicker.dataSource = self
        
        stepGoalPicker.reloadAllComponents()
        
        titleLabel.text = PropertyUtils.readLocalizedProperty("Setting Step Goal")
        cancelButton.setTitle(PropertyUtils.readLocalizedProperty("Cancel"), for: .normal)
        doneButton.setTitle(PropertyUtils.readLocalizedProperty("Submit"), for: .normal)
    }
    
    @IBAction func doDismiss(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func donePressAction(_ sender: UIButton) {
        
        //身高：61cm~241cm (參考 moto)
        //體重：3kg~120kg (參考小米)
        
        let index = stepGoalPicker.selectedRow(inComponent: 0)
        selectItem = goalArray[index]
        
        print(selectItem)
        settingDelegate?.updateSettingTableView(stepGoal: selectItem)
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // UIPickerViewDataSource 必須實作的方法：UIPickerView 有幾列可以選擇
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // UIPickerViewDataSource 必須實作的方法：UIPickerView 各列有多少行資料
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // 設置第一列時
        //if component == 0 {
        //    return heightArray.count
        //}
        
        // 否則就是設置第二列
        // 返回陣列 meals 的成員數量
        return goalArray.count
    }
    
    // UIPickerView 每個選項顯示的資料
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 設置第一列時
        //if component == 0 {
        // 設置為陣列 week 的第 row 項資料
        //    return week[row]
        //}
        
        // 否則就是設置第二列
        // 設置為陣列 meals 的第 row 項資料
        return goalArray[row]
    }
    
    
    // UIPickerView 改變選擇後執行的動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 改變第一列時
        //if component == 0 {
        // whatDay 設置為陣列 week 的第 row 項資料
        //whatDay = week[row]
        //} else {
        // 否則就是改變第二列
        // whatMeal 設置為陣列 meals 的第 row 項資料
        //whatMeal = meals[row]
        //}
        
        // selectItem = heightArray[row]
        // 將改變的結果印出來
        //print("選擇的是 \(selectItem)")
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
