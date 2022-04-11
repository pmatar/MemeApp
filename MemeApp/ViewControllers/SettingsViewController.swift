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
    
    private var selectedCount: String?
    private var selectedSubreddit: String?
    private var count: [String] = []
    private var subreddit: [String] = []
    
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        memePicker.delegate = self
        memePicker.dataSource = self
        subredditPicker.delegate = self
        subredditPicker.dataSource = self
        
        memePicker.selectRow(0, inComponent: 0, animated: false)
        subredditPicker.selectRow(0, inComponent: 0, animated: false)
        
        count = Array(1...50).map { String($0) }
        subreddit = ["memes", "dankmemes", "me_irl", "wholesomememes", "default"]
        
        selectedCount = count[memePicker.selectedRow(inComponent: 0)]
        selectedSubreddit = subreddit[subredditPicker.selectedRow(inComponent: 0)]
    }
    
    @IBAction func savePuttonPressed() {
        if let selectedCount = selectedCount, let selectedSubreddit = selectedSubreddit {
            delegate?.setup(count: selectedCount, subreddit: selectedSubreddit)
        }
        dismiss(animated: true)
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case memePicker: return count.count
        default: return subreddit.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case memePicker: return count[row]
        default: return subreddit[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case memePicker: selectedCount = count[row]
        default: selectedSubreddit = subreddit[row]
        }
    }
    
}
