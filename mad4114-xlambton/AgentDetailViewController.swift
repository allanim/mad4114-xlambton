//
//  AgentDetailViewController.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-09.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import UIKit
import CoreData

class AgentDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMission: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    var context: NSManagedObjectContext {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func fetch() -> [CountryEntity] {
        return try! context.fetch(CountryEntity.fetchRequest())
    }
    
    var countries: [CountryEntity] {
        return self.fetch().sorted(by: { $0.name! < $1.name! })
    }
    
    var countryPicker = UIPickerView()
    var missionPicker = UIPickerView()
    var datePicker = UIDatePicker()
    
    var editAgent: Agent!
    var selectedCountry: CountryEntity!
    var selectedMission: Missiontype!
    var selectedDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if StoreUtils.isSQLite {
            if let edit = editAgent {
                
                let agent = StoreUtils.decryptAgent(edit)
                
                self.txtName.text = agent.name
                
                self.selectedMission = Missiontype(rawValue: agent.mission)
                self.txtMission.text = agent.mission
                
                self.selectedCountry = getCountry(code: agent.country)
                self.txtCountry.text = self.selectedCountry.name
                
                self.selectedDate = agent.date
                self.txtDate.text = showDate(agent.date)
                
                self.txtEmail.text = agent.email
            }
        } else {
            if let edit = editAgent, let agent = edit.getEntity() {
                
                StoreUtils.decryptAgent(agent)
                
                self.txtName.text = agent.name
                
                self.selectedMission = Missiontype(rawValue: agent.mission!)
                self.txtMission.text = agent.mission
                
                self.selectedCountry = getCountry(code: agent.country!)
                self.txtCountry.text = self.selectedCountry.name
                
                self.selectedDate = agent.date
                self.txtDate.text = showDate(agent.date!)
                
                self.txtEmail.text = agent.email
            }
        }
        
        
        txtMission.delegate = self
        txtCountry.delegate = self
        txtDate.delegate = self
        
        pickUpMission()
        pickUpCountry()
        pickUpDate()
    }
    
    func getCountry(code: String) -> CountryEntity? {
        for country in countries {
            if country.code == code {
                return country
            }
        }
        return nil
    }
    
    func getCountryRow(code: String) -> Int {
        var row = 0;
        for country in countries {
            if country.code == code {
                return row
            } else {
                row += 1
            }
        }
        return row
    }
    
    func showDate(_ date: String) -> String {
        return date.prefix(2) + "/" + date.prefix(4).suffix(2) + "/" + date.suffix(4)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnSave(_ sender: Any) {
        if self.txtName.text == ""
            || self.txtCountry.text == ""
            || self.txtMission.text == ""
            || self.txtDate.text == ""
            || self.txtEmail.text == "" {
            
            let alert = UIAlertController(title: nil, message: "Please input Data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        if StoreUtils.isSQLite {
            if editAgent != nil {
                editAgent.name = self.txtName.text!
                editAgent.country = self.selectedCountry.code!
                editAgent.mission = self.selectedMission.rawValue
                editAgent.date = self.selectedDate
                editAgent.email = self.txtEmail.text!
                
                var _ = SQLiteDatahandler.saveAent(StoreUtils.encryptAgent(editAgent))
            } else {
                let agent = Agent(id: 0, name: self.txtName.text!, country: self.selectedCountry.code!, mission: self.selectedMission, date: self.selectedDate, email: self.txtEmail.text!)
                
                var _ = SQLiteDatahandler.saveAent(StoreUtils.encryptAgent(agent))
            }
        } else {
            do {
                if let edit = editAgent, let agent = edit.getEntity() {
                    agent.name = self.txtName.text
                    agent.country = self.selectedCountry.code
                    agent.mission = self.selectedMission.rawValue
                    agent.date = self.selectedDate
                    agent.email = self.txtEmail.text
                    
                    StoreUtils.encryptAgent(agent)
                } else {
                    let agent = AgentEntity(context: context)
                    agent.name = self.txtName.text
                    agent.country = self.selectedCountry.code
                    agent.mission = self.selectedMission.rawValue
                    agent.date = self.selectedDate
                    agent.email = self.txtEmail.text
                    
                    StoreUtils.encryptAgent(agent)
                }
                try context.save()
                print("SAVED")
            } catch {
                context.rollback()
                print("ROLLBACK")
            }
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension AgentDetailViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if countryPicker == pickerView {
            return countries.count
        } else if missionPicker == pickerView {
            return StoreUtils.missions.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if countryPicker == pickerView {
            return countries[row].name
        } else if missionPicker == pickerView {
            return StoreUtils.missions[row].rawValue
        } else {
            return ""
        }
    }
    
    func pickUpMission(){
        
        // input view
        self.missionPicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 150))
        self.missionPicker.backgroundColor = .white
        self.missionPicker.delegate = self
        self.txtMission.inputView = self.missionPicker
        
        if let mission = selectedMission {
            missionPicker.selectRow(StoreUtils.rowMissions(mission), inComponent: 0, animated: true)
        }
        
        // ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.pickUpMissionDoneClick))
        let cancelButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.pickUpMissionCancelClick))
        self.txtMission.inputAccessoryView = makeToolBar(done: doneButton, cancel: cancelButton)
        
    }
    
    @objc private func pickUpMissionDoneClick() {
        let mission =  StoreUtils.missions[missionPicker.selectedRow(inComponent: 0)]
        self.txtMission.text = mission.rawValue
        self.txtMission.resignFirstResponder()
        self.selectedMission = mission
    }
    
    @objc func pickUpMissionCancelClick() {
        self.txtMission.resignFirstResponder()
    }
    
    func pickUpCountry(){
        
        // input view
        self.countryPicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 230))
        self.countryPicker.backgroundColor = .white
        self.countryPicker.delegate = self
        self.txtCountry.inputView = self.countryPicker
        
        if let country = selectedCountry {
            countryPicker.selectRow(self.getCountryRow(code: country.code!), inComponent: 0, animated: true)
        }
        
        // ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.pickUpCountryDoneClick))
        let cancelButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.pickUpCountryCancelClick))
        self.txtCountry.inputAccessoryView = makeToolBar(done: doneButton, cancel: cancelButton)
        
    }
    
    @objc private func pickUpCountryDoneClick() {
        let country = countries[countryPicker.selectedRow(inComponent: 0)];
        self.txtCountry.text = country.name
        self.txtCountry.resignFirstResponder()
        self.selectedCountry = country
    }
    
    @objc func pickUpCountryCancelClick() {
        self.txtCountry.resignFirstResponder()
    }
    
    func pickUpDate() {
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = .white
        self.datePicker.datePickerMode = .date
        self.txtDate.inputView = self.datePicker
        
        // ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.datePickerDoneClick))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.datePickerCancelClick))
        self.txtDate.inputAccessoryView = self.makeToolBar(done: doneButton, cancel: cancelButton)
    }
    
    @objc private func datePickerDoneClick() {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        
        self.txtDate.text = df.string(from: self.datePicker.date)
        self.txtDate.resignFirstResponder()
        self.selectedDate = self.txtDate.text?.replacingOccurrences(of: "/", with: "")
    }
    
    @objc func datePickerCancelClick() {
        self.txtDate.resignFirstResponder()
    }
    
    func makeToolBar(done: UIBarButtonItem, cancel: UIBarButtonItem) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancel, spaceButton, done], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
}
