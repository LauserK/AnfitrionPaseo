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
    
    // Vectores para la data de los UIPickerView
    var identidadArray: [String] = [String]()
    var operadoraArray: [String] = [String]()
    
    //Determinar funcion del boton para ingresar a la cola
    var registrarCliente: Bool = false
    
    // Objetos con la base de informacion de clientes y contribuyentes
    var cliente = [
        "auto": "",
        "razon_social": "",
        "ci_rif": "",
        "dir_fiscal": "",
        "celular": "",
        "fecha_nacimiento": ""
    ]
    
    var contribuyente = [
        "auto": "",
        "razon_social": "",
        "ci_rif": "",
        "dir_fiscal": "",
        "celular": "",
        "fecha_nacimiento": ""
    ]
    
    var auto_cuenta = ""
    
    var cedula:String = ""
    var tipoSegue: String = ""
    
    // Set border to inputs
    func setBorders(){
        
        let borderWidth = CGFloat(2)
        let cornerRadius = CGFloat(5)
        // Cedula
        self.cedulaTxt.layer.borderColor = UIColor(red: 161/255, green: 132/255, blue: 24/255, alpha: 1.0).cgColor
        self.cedulaTxt.layer.borderWidth = borderWidth
        self.cedulaTxt.layer.cornerRadius = cornerRadius
        // Nombre
        self.nombreTxt.layer.borderColor = UIColor(red: 161/255, green: 132/255, blue: 24/255, alpha: 1.0).cgColor
        self.nombreTxt.layer.borderWidth = borderWidth
        self.nombreTxt.layer.cornerRadius = cornerRadius
        // Nombre Contribuyente
        self.nombreLabel.layer.borderColor = UIColor(red: 161/255, green: 132/255, blue: 24/255, alpha: 1.0).cgColor
        self.nombreLabel.layer.borderWidth = borderWidth
        self.nombreLabel.layer.cornerRadius = cornerRadius
        // Municipio del contribuyente
        self.municipioTxt.layer.borderColor = UIColor(red: 161/255, green: 132/255, blue: 24/255, alpha: 1.0).cgColor
        self.municipioTxt.layer.borderWidth = borderWidth
        self.municipioTxt.layer.cornerRadius = cornerRadius
        // Municipio del contribuyente
        self.numeroTxt.layer.borderColor = UIColor(red: 161/255, green: 132/255, blue: 24/255, alpha: 1.0).cgColor
        self.numeroTxt.layer.borderWidth = borderWidth
        self.numeroTxt.layer.cornerRadius = cornerRadius
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.limpiar()
        self.setBorders()
        self.cedulaTxt.text = cedula
        
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
        let nombre = nombreTxt.text!
        
        // Municipio
        let municipio = municipioTxt.text!
        
        // Numero celular
        let operadora = String(operadoraArray[operadoraPicker.selectedRow(inComponent: 0)])
        let numeroCelular = "\(operadora!)\(numeroTxt.text!)"
        
        var fechaNacimiento = "2000-01-01"
        // Fecha de nacimiento solo si es persona natural
        if (tipoDocumento == "V" || tipoDocumento == "E"){
            let formater = DateFormatter()
            formater.dateFormat = "yyyy-MM-dd"
            let fechaNacimientoOld = nacimientoPicker.date
            fechaNacimiento = formater.string(from: fechaNacimientoOld)
        }
        
        //Abrir loading
        ToolsPaseo().loadingView(vc: self, msg: "Creando cliente...")
        
        // Insertar a la base de datos y regresar los datos al primer view
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT a_clientes FROM sistema_contadores limit 1"){ data in
            
            let auto = Int(ToolsPaseo().obtenerDato(s: data, i: 0))!
            let auto_nuevo = auto + 1
            let auto_cliente = String(format: "%010d", auto_nuevo)
            
            let sql = "INSERT INTO `00000001`.`clientes` (`auto`, `codigo`, `nombre`, `ci_rif`, `razon_social`, `auto_grupo`, `dir_fiscal`, `dir_despacho`, `contacto`, `telefono`, `email`, `website`, `pais`, `denominacion_fiscal`, `auto_estado`, `auto_zona`, `codigo_postal`, `retencion_iva`, `retencion_islr`, `auto_vendedor`, `tarifa`, `descuento`, `recargo`, `estatus_credito`, `dias_credito`, `limite_credito`, `doc_pendientes`, `estatus_morosidad`, `estatus_lunes`, `estatus_martes`, `estatus_miercoles`, `estatus_jueves`, `estatus_viernes`, `estatus_sabado`, `estatus_domingo`, `auto_cobrador`, `fecha_alta`, `fecha_baja`, `fecha_ult_venta`, `fecha_ult_pago`, `fecha_nacimiento`, `anticipos`, `debitos`, `creditos`, `saldo`, `disponible`, `memo`, `aviso`, `estatus`, `cuenta`, `iban`, `swit`, `auto_agencia`, `dir_banco`, `auto_codigo_cobrar`, `auto_codigo_ingresos`, `auto_codigo_anticipos`, `categoria`, `descuento_pronto_pago`, `importe_ult_pago`, `importe_ult_venta`, `telefono2`, `fax`, `celular`) VALUES ('\(auto_cliente)', '\(documentoIdentidad)', '\(nombre)', '\(documentoIdentidad)', '\(nombre)', '0000000001', '\(municipio)', '', '', '', '', '', '', 'No Contribuyente', '0000000001', '0000000001', '', '0.00', '0.00', '0000000001', '1', '0.00', '0.00', '', '0', '0.00', '0', '', '', '', '', '', '', '', '', '0000000001', '2000-01-01', '2000-01-01', '2000-01-01', '2000-01-01', '\(fechaNacimiento)', '0.00', '0.00', '0.00', '0.00', '0.00', '', '', 'Activo', '', '', '', '0000000001', '', '0000000001', '0000000001', '0000000001', 'Eventual', '0.00', '0.00', '0.00', '', '', '\(numeroCelular)')"
            
            ToolsPaseo().consultarDB(id: "open", sql: sql){ data in
                if (self.tipoSegue == "crearCliente"){
                    self.cliente = [
                        "auto": "",
                        "razon_social": nombre,
                        "ci_rif": documentoIdentidad,
                        "dir_fiscal": municipio,
                        "celular": numeroCelular,
                        "fecha_nacimiento": fechaNacimiento,
                        "created": "1"
                    ]
                } else {
                    self.contribuyente = [
                        "auto": "",
                        "razon_social": nombre,
                        "ci_rif": documentoIdentidad,
                        "dir_fiscal": municipio,
                        "celular": numeroCelular,
                        "fecha_nacimiento": fechaNacimiento,
                        "created": "1"
                    ]
                }
                
                
                if (self.tipoSegue == "crearCliente"){
                    let account = self.cliente["ci_rif"]!.substring(from:self.cliente["ci_rif"]!.index(self.cliente["ci_rif"]!.endIndex, offsetBy: -5))
                    // Busca la cuenta
                    ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto FROM pos_cuentas WHERE cuenta='\(account)'") { (data) in
                        let auto_cuenta = ToolsPaseo().obtenerDato(s: data, i: 0)
                        
                        // Si por alguna razon no se creo la cuenta, se crea al momento de traer la info
                        if (auto_cuenta == "" && self.cliente["ci_rif"] != "") {
                            ToolsPaseo().crearCuenta(ci_rif: self.cliente["ci_rif"]!)
                        }
                    }
                }
                
                
                let query = "UPDATE `00000001`.`sistema_contadores` SET `a_clientes` = '\(auto_nuevo)' WHERE a_clientes != '' LIMIT 1"
                ToolsPaseo().consultarDB(id: "open", sql: query){ (data) in
                    self.dismiss(animated: false){
                        self.performSegue(withIdentifier: "principal", sender: self)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "principal" {
            if let destination = segue.destination as? HomeController {
                destination.cliente = self.cliente
                destination.contribuyente = self.contribuyente
                destination.isReady = true
                
                if (self.contribuyente["razon_social"] != ""){
                    destination.contribuyenteCheck.backgroundColor = UIColor.green
                    destination.isContribuyenteCheck = true
                }
            }
        }
    }
}

