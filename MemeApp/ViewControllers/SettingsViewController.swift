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
    
    var selectedCount = ""
    var selectedSubreddit: String = "" {
        didSet {
            if selectedSubreddit == totalSubreddits[rowForDefaultSubreddit] {
                selectedCount = String(NetworkManager.shared.defaultMemes)
            }
        }
    }
    
    private var totalCount = Array(1...50).map { String($0) }
    private var totalSubreddits = NetworkManager.shared.defailtSubreddits
    private var rowForDefaultCount = NetworkManager.shared.defaultMemes - 1
    private var rowForDefaultSubreddit = NetworkManager.shared.defailtSubreddits.firstIndex(of: "default") ?? 0
    private var defaultRow = 0
    
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        memePicker.delegate = self
        memePicker.dataSource = self
        subredditPicker.delegate = self
        subredditPicker.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memePicker.selectRow(totalCount.firstIndex(of: selectedCount) ?? rowForDefaultCount, inComponent: 0, animated: false)
        subredditPicker.selectRow(totalSubreddits.firstIndex(of: selectedSubreddit) ?? rowForDefaultSubreddit, inComponent: 0, animated: true)
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
            defaultRow = row
        default:
            selectedSubreddit = totalSubreddits[row]
            if row == rowForDefaultSubreddit {
                memePicker.selectRow(rowForDefaultCount, inComponent: 0, animated: true)
                selectedCount = totalCount[rowForDefaultCount]
            } else {
                memePicker.selectRow(defaultRow, inComponent: 0, animated: true)
                selectedCount = totalCount[defaultRow]
            }
        }
    }
    
}
