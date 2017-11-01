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
    
    //Determinar funcion del boton para ingresar a la cola
    var registrarCliente: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inactivar los inputs hasta verificar la existencia del cliente en la DB
      /*self.nombreTxt.isEnabled = false
        self.municipioTxt.isEnabled = false
        self.numeroTxt.isEnabled = false
        self.operadoraPicker.isUserInteractionEnabled = false
        self.operadoraPicker.alpha = 0.5
        self.nacimientoPicker.isUserInteractionEnabled = false
        self.nacimientoPicker.alpha = 0.5
         */
        self.limpiar()
        
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
        
        // Seteamos una fecha de nacimiento
        let dateString = "2000-01-01"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        self.nacimientoPicker.setDate(date!, animated: false)
        
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Connect data:
        self.CedulaPicker.delegate = self
        self.CedulaPicker.dataSource = self
        self.operadoraPicker.delegate = self
        self.operadoraPicker.dataSource = self
        
        self.identidadArray = ["V", "E", "J", "G"]
        self.operadoraArray = ["0412", "0414", "0424","0416", "0426"]
    }
    
    func limpiar(){
        self.registrarCliente = false
        self.cedulaTxt.text = ""
        self.nombreTxt.text = ""
        self.municipioTxt.text = ""
        self.numeroTxt.text = ""
        self.isPanaderiaCheck = false
        self.isPasteleriaCheck = false
        self.isCharcuteriaCheck = false
        self.pasteleriaCheck.backgroundColor = UIColor.lightGray
        self.panaderiaCheck.backgroundColor = UIColor.lightGray
        self.charcuteriaCheck.backgroundColor = UIColor.lightGray
        self.nombreTxt.isEnabled = false
        self.municipioTxt.isEnabled = false
        self.numeroTxt.isEnabled = false
        self.operadoraPicker.isUserInteractionEnabled = false
        self.operadoraPicker.alpha = 0.5
        self.nacimientoPicker.isUserInteractionEnabled = false
        self.nacimientoPicker.alpha = 0.5
    }
    
    // Cuando se hace tap quita el keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Picker functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Seteamos el row a 1
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView == CedulaPicker){
            return identidadArray.count
        } else if(pickerView == operadoraPicker) {
            return operadoraArray.count
        }
        
        return 1
    }
    
    // Seteamos los arreglos(data) a los picker
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
    
    // Verificar si existe el cliente
    @IBAction func checkClienteBtn(_ sender: Any) {
        // Cerramos el teclado
        dismissKeyboard()
        
        // Presentamos el loader
        ToolsPaseo().loadingView(vc: self, msg: "Buscando cliente...")
        
        // Cedula de identidad o R.I.F del comprador
        let tipoDocumento = String(identidadArray[CedulaPicker.selectedRow(inComponent: 0)])
        let documentoIdentidad = "\(tipoDocumento!)\(cedulaTxt.text!)"
        
        // Realizamos a consulta a la base de datos
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto, razon_social,ci_rif, dir_fiscal, celular, fecha_nacimiento FROM clientes WHERE ci_rif='\(documentoIdentidad)' and estatus='Activo'") { (data) in
            
            // Quitamos el loading y como callback lo que debe hacer
            self.dismiss(animated:false){
                // Objeto con la informacion de los clientes
                let cliente = [
                    "auto": ToolsPaseo().obtenerDato(s: data, i: 0),
                    "razon_social": ToolsPaseo().obtenerDato(s: data, i: 1),
                    "ci_rif": ToolsPaseo().obtenerDato(s: data, i: 2),
                    "dir_fiscal": ToolsPaseo().obtenerDato(s: data, i: 3),
                    "celular": ToolsPaseo().obtenerDato(s: data, i: 4),
                    "fecha_nacimiento": ToolsPaseo().obtenerDato(s: data, i: 5)
                ]
                
                if (cliente["auto"] == ""){
                    let cedula = self.cedulaTxt.text!
                    self.limpiar()
                
                    // Activamos que debemos de registrar el cliente
                    self.registrarCliente = true
                    
                    let alerta = UIAlertController(title: "El cliente no existe", message: "Desea crearlo?", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Si", style: UIAlertActionStyle.default, handler: { (action) in
                        /*
                         Si la opcion es 'SI' al cliente se habilian los campos
                         */
                        self.cedulaTxt.text = cedula
                        self.nombreTxt.isEnabled = true
                        self.municipioTxt.isEnabled = true
                        self.numeroTxt.isEnabled = true
                        self.operadoraPicker.isUserInteractionEnabled = true
                        self.operadoraPicker.alpha = 1
                        self.nacimientoPicker.isUserInteractionEnabled = true
                        self.nacimientoPicker.alpha = 1
                    }))
                    alerta.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alerta, animated: true, completion: nil)
                    
                    
                } else {
                    // Desactivamos que hay que registar el cliente
                    self.registrarCliente = false
                    
                    // si el cliente ya existe se ingresa la informacion a los inputs siguiendo deshabilitados
                    self.nombreTxt.text = cliente["razon_social"]
                    self.municipioTxt.text = cliente["dir_fiscal"]
                    
                    // Si existe numero celular en la base datos
                    if (cliente["celular"] != "") {
                        // Obtener el numero sin la operadora
                        var index = cliente["celular"]!.index(cliente["celular"]!.startIndex, offsetBy: 4)
                        var numero = cliente["celular"]!.substring(from: index)
                        self.numeroTxt.text = numero
                        
                        //Obtener la operadora
                        numero = cliente["celular"]!.substring(to:cliente["celular"]!.index(cliente["celular"]!.startIndex, offsetBy: 4))
                    
                        if (numero == "0412") {
                            self.operadoraPicker.selectRow(0, inComponent: 0, animated: true)
                        } else if (numero == "0414") {
                            self.operadoraPicker.selectRow(1, inComponent: 0, animated: true)
                        } else if (numero == "0424") {
                            self.operadoraPicker.selectRow(2, inComponent: 0, animated: true)
                        } else if (numero == "0416") {
                            self.operadoraPicker.selectRow(3, inComponent: 0, animated: true)
                        } else if (numero == "0426"){
                            self.operadoraPicker.selectRow(4, inComponent: 0, animated: true)
                        }
                    }
                    
                    if(cliente["fecha_nacimiento"] != ""){
                        let dateString = cliente["fecha_nacimiento"]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: dateString!)
                        self.nacimientoPicker.setDate(date!, animated: false)
                    }
                }
            }
        }
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
        
        // Insertar a la base de datos
        
        if(registrarCliente){
            
            
        }
    }
    
    
    // Cuando seleciona la seccion panaderia
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
    
    // Cuando seleciona la seccion pasteleria
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
    
    // Cuando seleciona la seccion Charcuteria
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

