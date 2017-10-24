//
//  ViewController.swift
//  Anfitrion Paseo
//
//  Created by Kildare Lauser on 19/10/17.
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
    
    // variables para los pseudocheckbox
    var isPanaderiaCheck   = false
    var isCharcuteriaCheck = false
    var isPasteleriaCheck  = false
    
    // Vectores para la data de los UIPickerView
    var identidadArray: [String] = [String]()
    var operadoraArray: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inactivar los inputs hasta verificar la existencia del cliente en la DB
        self.nombreTxt.isEnabled = false
        self.municipioTxt.isEnabled = false
        self.numeroTxt.isEnabled = false
        self.operadoraPicker.isUserInteractionEnabled = false
        self.operadoraPicker.alpha = 0.5
        self.nacimientoPicker.isUserInteractionEnabled = false
        self.nacimientoPicker.alpha = 0.5
        
        
        // Seteamos el formato Day-Month-Year al Picker
        self.nacimientoPicker.datePickerMode = .date
        
        // Variables para el minimo y maximo
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        // Setear maximo una edad maxima de 100 anos apartir de hoy
        components.year = -100
        let minDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        self.nacimientoPicker.minimumDate = minDate as Date
        
        // Setear una fecha minima a 7 anos a partir de hoy
        components.year = -7
        let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        self.nacimientoPicker.maximumDate = maxDate as Date
        
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
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
    
    /*
     Dependiendo del tipo de cliente se cambia el label
     y el estado del UIPickerView(Fecha Nacimiento)
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == CedulaPicker){
            let state = identidadArray[row]
            
            if (state == "J" || state == "G") {
                nombreLabel.text = "Razón social"
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
    
    // Verificar si existe el cliente
    @IBAction func checkClienteBtn(_ sender: Any) {
        nombreTxt.isEnabled = true
        municipioTxt.isEnabled = true
        numeroTxt.isEnabled = true
        self.operadoraPicker.isUserInteractionEnabled = true
        self.operadoraPicker.alpha = 1
        self.nacimientoPicker.isUserInteractionEnabled = true
        self.nacimientoPicker.alpha = 1
    }
    
    // Enviar la informacion a la base de datos
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

