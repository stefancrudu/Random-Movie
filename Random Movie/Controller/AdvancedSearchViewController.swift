//
//  AdvancedSearchViewController.swift
//  Random Movie
//
//  Created by Stefan Crudu on 17.02.2021.
//

import UIKit

protocol AdvancedSearchDelegate: class {
    func didChangeAdvancedSearch(with model: AdvancedSearchModel)
}

class AdvancedSearchViewController: UIViewController {

    weak var delegate: AdvancedSearchDelegate?
    var searchModel: AdvancedSearchModel = AdvancedSearchModel.default
    var formContent: AdvancedSearchModel?
    var selectedGeners: [Int: String] = [:] {
        didSet {
            clearAllButton.isHidden = selectedGeners.isEmpty
            genersTableView.reloadData()
        }
    }
    
    @IBOutlet var fromYearTextField: UITextField!
    @IBOutlet var toYearTextField: UITextField!
    @IBOutlet var fromRatingTextField: UITextField!
    @IBOutlet var toRatingTextField: UITextField!
    @IBOutlet var genersTableView: UITableView! {
        didSet {
            genersTableView.dataSource = self
            genersTableView.delegate = self
        }
    }
    @IBOutlet var clearAllButton: UIButton! {
        didSet {
            clearAllButton.isHidden = selectedGeners.isEmpty
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegateForTextFields()
        loadSevedForm()
        dismissKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let fromYear = fromYearTextField.text,
           let toYear = toYearTextField.text,
           let fromRating = fromRatingTextField.text,
           let toRating = toRatingTextField.text {
            formContent = AdvancedSearchModel(fromYear: fromYear, toYear: toYear, fromRating: fromRating, toRating: toRating, geners: selectedGeners)
        
            delegate?.didChangeAdvancedSearch(with: formContent!)
        }
    }
    
    @IBAction func clearGenersButtonPressed(_ sender: UIButton) {
        for cell in selectedGeners {
            if let cellFromTable = genersTableView.cellForRow(at: IndexPath(row: cell.key, section: 0)) {
                cellFromTable.accessoryType = .none
            }
        }
        selectedGeners.removeAll()
    }
}

//MARK: - TableViewDataSource -

extension AdvancedSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdvancedSearchModel.genersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = AdvancedSearchModel.genersList[indexPath.row]
        if selectedGeners.keys.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
}

//MARK: - TableViewDelegate -

extension AdvancedSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
            if let gener = cell.textLabel?.text {
                if selectedGeners[indexPath.row] != nil {
                    selectedGeners.removeValue(forKey: indexPath.row)
                } else {
                    selectedGeners[indexPath.row] = gener
                }
                searchModel.geners = selectedGeners
                
                delegate?.didChangeAdvancedSearch(with: searchModel)
            }
        }
    }
}

//MARK: - UITextFieldDelegate -

extension AdvancedSearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case fromYearTextField:
            let defaultValue = "1970"
            if textField.text?.count == 4 {
                textField.text = checkYear(textField.text ?? "")
            } else {
                textField.text = defaultValue
            }
            textField.text = textField.text!.isEmpty ? defaultValue : textField.text

            searchModel.fromYear = textField.text ?? defaultValue
            
        case toYearTextField:
            let defaultValue = "\(Calendar.current.component(.year, from: Date()))"
            if textField.text?.count == 4 {
                textField.text = checkYear(textField.text ?? "")
            } else {
                textField.text = defaultValue
            }
            textField.text = textField.text!.isEmpty ? defaultValue : textField.text

            searchModel.toYear = textField.text ?? defaultValue
            
        case fromRatingTextField:
            let defaultValue = "0"
            if textField.text!.count <= 2 {
                textField.text = checkRank(textField.text ?? "0")
            } else {
                textField.text = defaultValue
            }
            textField.text = textField.text!.isEmpty ? defaultValue : textField.text

            searchModel.fromRating = textField.text ?? defaultValue
            
        case toRatingTextField:
            let defaultValue = "10"
            if textField.text!.count <= 2 {
                textField.text = checkRank(textField.text ?? "10")
            } else {
                textField.text = defaultValue
            }
            textField.text = textField.text!.isEmpty ? defaultValue : textField.text
            
            searchModel.toRating = textField.text ?? defaultValue
        default:
            break
        }
        
        delegate?.didChangeAdvancedSearch(with: searchModel)
    }
}

//MARK: - Keyboard Configuration -

extension AdvancedSearchViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
        
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}

//MARK: - Privates -

extension AdvancedSearchViewController {
    private func setupDelegateForTextFields() {
        for textField in [fromYearTextField, toYearTextField, fromRatingTextField, toRatingTextField] {
            textField?.delegate = self
        }
    }
    
    private func setupUI() {
        fromYearTextField.text = searchModel.fromYear
        toYearTextField.text = searchModel.toYear
        fromRatingTextField.text = searchModel.fromRating
        toRatingTextField.text = searchModel.toRating
        
        selectedGeners = searchModel.geners
    }
    
    private func loadSevedForm() {
        if let formContent = formContent {
            fromYearTextField.text = formContent.fromYear
            toYearTextField.text = formContent.toYear
            fromRatingTextField.text = formContent.fromRating
            toRatingTextField.text = formContent.toRating
            selectedGeners = formContent.geners
        }
    }
    
    private func checkYear(_ value: String) -> String{
        if let valueNumber = Int(value) {
            if valueNumber < 1970 {
                return "1970"
            } else if valueNumber < Int(fromYearTextField.text!)! {
                return fromYearTextField.text!
            } else if valueNumber > Calendar.current.component(.year, from: Date()) {
                return "\(Calendar.current.component(.year, from: Date()))"
            }
        }
        return value
    }
    
    private func checkRank(_ value: String) -> String {
        if let valueNumber = Int(value) {
            if valueNumber < 0 {
                return "0"
            } else if valueNumber < Int(fromRatingTextField.text!)! {
                return fromRatingTextField.text!
            } else if valueNumber > 10 {
                return "10"
            }
        }
        return value
    }
}
