//
//  SettingsViewController.swift
//  MemeApp
//
//  Created by Paul Matar on 11.04.2022.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var memePicker: UIPickerView!
    @IBOutlet weak var subredditPicker: UIPickerView!
    
    var selectedCount: String = "20"
    var selectedSubreddit: String = "" {
        didSet{
            if selectedSubreddit == "default" {
                selectedCount = "20"
            }
        }
    }

    private var totalCount: [String] = []
    private var totalSubreddits: [String] = []
    private var selectedCountRow = 0
    
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        memePicker.delegate = self
        memePicker.dataSource = self
        subredditPicker.delegate = self
        subredditPicker.dataSource = self
        
        selectedCountRow = (Int(selectedCount) ?? 1) - 1
        
        totalCount = Array(1...50).map { String($0) }
        totalSubreddits = ["memes", "dankmemes", "me_irl", "wholesomememes", "default"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memePicker.selectRow(totalCount.firstIndex(of: selectedCount) ?? 19, inComponent: 0, animated: false)
        subredditPicker.selectRow(totalSubreddits.firstIndex(of: selectedSubreddit) ?? 0, inComponent: 0, animated: true)
    }
    
    @IBAction func savePuttonPressed() {
        delegate?.setup(count: selectedCount, subreddit: selectedSubreddit)
        dismiss(animated: true)
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case memePicker:
            return totalCount.count
        default:
            return totalSubreddits.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case memePicker:
            return totalCount[row]
        default:
            return totalSubreddits[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case memePicker:
            selectedCount = totalCount[row]
            selectedCountRow = row
        default:
            selectedSubreddit = totalSubreddits[row]
            if row == 4 {
                memePicker.selectRow(19, inComponent: 0, animated: true)
            } else {
                memePicker.selectRow(selectedCountRow, inComponent: 0, animated: true)
            }
        }
    }
    
}
