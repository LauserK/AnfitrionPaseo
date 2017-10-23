//
//  ViewController.swift
//  Anfitrion Paseo
//
//  Created by Macbook on 19/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var CedulaPicker: UIPickerView!
    @IBOutlet weak var cedulaTxt: UITextField!
    @IBOutlet weak var nacimientoPicker: UIDatePicker!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var operadoraPicker: UIPickerView!
    @IBOutlet weak var nombreTxt: UITextField!
    @IBOutlet weak var municipioTxt: UITextField!
    @IBOutlet weak var numeroTxt: UITextField!
    
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
    
    @IBAction func sendBtn(_ sender: Any) {
        /*
         Parametros del request
            * Documento de identidad: "(tipoDocumento)(numeroDocumento)"
            * Nombre y apellido / Razon social: "string"
            * Municipio: "sring"
            * Numero celular: "(numeroOperadora)(numeroCelular)"
            * Fecha de nacimiento / Solo personas naturales: "(year)-(month)-(day)"
            * Area / Sección a agregar: "01" | 01: Caja, 02: CAFETERIA, 03: CHARCUTERIA, 04: PANADERIA, 05: PIZZERIA
         
         
         */
        
        // Cedula de identidad o R.I.F del comprador
        let tipoDocumento = String(identidadArray[CedulaPicker.selectedRow(inComponent: 0)])
        let documentoIdentidad = "\(tipoDocumento!)\(cedulaTxt.text!)"
        
        // Nombre y Apellido o Razon Socal del comprador
        let nombre = nombreTxt!
        
        // Municipio
        let municipio = municipioTxt!
        
        // Numero celular
        let operadora = String(operadoraArray[operadoraPicker.selectedRow(inComponent: 0)])
        let numeroCelular = "\(operadora!)\(numeroTxt.text!)"
        
        // Fecha de nacimiento solo si es persona natural
        if (tipoDocumento == "V" || tipoDocumento == "E"){
            var formater = DateFormatter()
            formater.dateFormat = "yyyy-MM-dd"
            let fechaNacimientoOld = nacimientoPicker.date
            let fechaNacimiento = formater.string(from: fechaNacimientoOld)
        } else {
            let fechaNacimiento = ""
        }
        
        // Seccion a la cual se va a agregar a la cola virtual
        var seccion = ""
        if (isPanaderiaCheck == true){
            seccion = "04"
        } else if (isCharcuteriaCheck == true){
            seccion = "03"
        } else if (isPasteleriaCheck == true) {
            seccion = "06"
        }
        
        Alamofire.request("http://10.10.0.199:8083").response { response in
            print("Request: \(response.request)")
            print("Response: \(response.response)")
            print("Error: \(response.error)")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
    }
}

