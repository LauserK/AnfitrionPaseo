//
//  ViewController.swift
//  Anfitrion Paseo
//
//  Created by Macbook on 19/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var CedulaPicker: UIPickerView!
    @IBOutlet weak var cedulaTxt: UITextField!
    @IBOutlet weak var nacimientoPicker: UIDatePicker!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var operadoraPicker: UIPickerView!
    
    // pseudocheckboxs
    @IBOutlet weak var panaderiaCheck: UIButton!
    @IBOutlet weak var pasteleriaCheck: UIButton!
    @IBOutlet weak var charcuteriaCheck: UIButton!
    
    // variables for pseudocheckbox
    var isPanaderiaCheck   = false
    var isCharcuteriaCheck = false
    var isPasteleriaCheck  = false
    
    // inicialize the array for picker data
    var identidadArray: [String] = [String]()
    var operadoraArray: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set day, month, year picker
        nacimientoPicker.datePickerMode = .date
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        // Set maximun 100 years old
        components.year = -100
        let minDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        self.nacimientoPicker.minimumDate = minDate as Date
        
        // Set minimun 7 years old
        components.year = -7
        let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        self.nacimientoPicker.maximumDate = maxDate as Date
        
        // when click anywhere dismiss the keyboard
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Connect data:
        self.CedulaPicker.delegate = self
        self.CedulaPicker.dataSource = self
        self.operadoraPicker.delegate = self
        self.operadoraPicker.dataSource = self
        
        identidadArray = ["V", "E", "J", "G"]
        operadoraArray = ["0412", "0414", "0424","0416", "0426"]
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Picker functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView == CedulaPicker){
            return identidadArray.count
        } else if(pickerView == operadoraPicker) {
            return operadoraArray.count
        }
        
        return 1
    }
    
    // set the data to the picker
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        
        if (pickerView == CedulaPicker){
            return identidadArray[row]
        } else if (pickerView == operadoraPicker) {
            return operadoraArray[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == CedulaPicker){
            let state = identidadArray[row]
            
            if (state == "J" || state == "G") {
                nombreLabel.text = "Razón Social"
                nacimientoPicker.isUserInteractionEnabled = false
                nacimientoPicker.alpha = 0.5
            } else {
                nombreLabel.text = "Nombre y apellido"
                nacimientoPicker.isUserInteractionEnabled = true
                nacimientoPicker.alpha = 1
            }
        }
    }
    
    //Checkbox funtions
    @IBAction func clickPanaderiaCheck(_ sender: Any) {
        if (isPanaderiaCheck == false) {
            panaderiaCheck.backgroundColor = UIColor.green
            pasteleriaCheck.backgroundColor = UIColor.lightGray
            charcuteriaCheck.backgroundColor = UIColor.lightGray
            isPanaderiaCheck = true
            isPasteleriaCheck = false
            isCharcuteriaCheck = false
            
        }
    }
    
    @IBAction func clickPasteleriaCheck(_ sender: Any) {
        if (isPasteleriaCheck == false) {
            pasteleriaCheck.backgroundColor = UIColor.green
            panaderiaCheck.backgroundColor = UIColor.lightGray
            charcuteriaCheck.backgroundColor = UIColor.lightGray
            isPasteleriaCheck = true
            isPanaderiaCheck = false
            isCharcuteriaCheck = false
        }
    }
    
    @IBAction func clickCharcuteriaCheck(_ sender: Any) {
        if (isCharcuteriaCheck == false) {
            charcuteriaCheck.backgroundColor = UIColor.green
            pasteleriaCheck.backgroundColor = UIColor.lightGray
            panaderiaCheck.backgroundColor = UIColor.lightGray
            isCharcuteriaCheck = true
            isPanaderiaCheck = false
            isPasteleriaCheck = false
        }
    }
    
}

