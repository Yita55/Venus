
import UIKit

class CustomWeightAlertVC : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var weightPicker: UIPickerView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    
    let transitioner = CAVTransitioner()
    
    var plistManager = PlistManager()

    var settingDelegate: SettingViewDelegate?
    
    
    var weightArray = [String]()
    
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
        
        // 設定 UIPickerView 的 delegate 及 dataSource
        //身高：61cm~241cm (參考 moto)
        //體重：3kg~120kg (參考小米)
        
        for i in 3..<121 {
            let item: String = "\(i)"
            weightArray.append(item)
        }
        
        weightPicker.delegate = self
        weightPicker.dataSource = self
        
        
        weightPicker.reloadAllComponents()
        // format for picker
        
        titleLabel.text = PropertyUtils.readLocalizedProperty("Setting Weight")
        cancelBtn.setTitle(PropertyUtils.readLocalizedProperty("Cancel"), for: .normal)
        doneBtn.setTitle(PropertyUtils.readLocalizedProperty("Submit"), for: .normal)
        
    }
    
    @IBAction func doDismiss(_ sender:Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func donePressAction(_ sender: UIButton) {
        
        
        let index = weightPicker.selectedRow(inComponent: 0)
        selectItem = weightArray[index]
        
        print(selectItem)
        
        settingDelegate?.updateSettingTableView(weight: selectItem)
        
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
        return weightArray.count
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
        return weightArray[row]
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
        
        //selectItem = weightArray[row]
        // 將改變的結果印出來
        print("選擇的是 \(selectItem)")
    }
    
}
