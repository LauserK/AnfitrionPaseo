//
//  ViewController.swift
//  Anfitrion Paseo
//
//  Created by Kildare Lauser on 19/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import UIKit

class HomeController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var cedulaPicker: UIPickerView!
    @IBOutlet weak var cedulaTxt: UITextField!
    @IBOutlet weak var nombreTxt: UITextField!
    @IBOutlet weak var contribuyenteCheck: UIButton!
    @IBOutlet weak var contribuyentePicker: UIPickerView!
    @IBOutlet weak var cedulaContribuyenteTxt: UITextField!
    @IBOutlet weak var contribuyenteTxt: UITextField!
    @IBOutlet weak var irAColaVirtualBtn: UIButton!
    @IBOutlet weak var validarCliente: UIButton!
    @IBOutlet weak var validarContribuyente: UIButton!
    
    /*
     Variables para checkbox
     */
    @IBOutlet weak var panaderiaCheck: UIButton!
    @IBOutlet weak var pasteleriaCheck: UIButton!
    @IBOutlet weak var charcuteriaCheck: UIButton!
    
    // variables para los pseudocheckbox
    var isPanaderiaCheck     = false
    var isCharcuteriaCheck   = false
    var isPasteleriaCheck    = false
    var isContribuyenteCheck = false
    
    // Vectores para la data de los UIPickerView
    let identidadArray: [String] = ["V", "E"]
    let contribuyenteArray: [String] = ["V", "E", "J", "G"]
    
    // Verificar si esta todo OK para poder registrar
    var isReady: Bool = false
    
    // Objetos con la base de informacion de clientes y contribuyentes
    var cliente = [
        "auto": "",
        "razon_social": "",
        "ci_rif": "",
        "dir_fiscal": "",
        "celular": "",
        "fecha_nacimiento": "",
        "created": ""
    ]
    
    var contribuyente = [
        "auto": "",
        "razon_social": "",
        "ci_rif": "",
        "dir_fiscal": "",
        "created":""
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.cliente["created"] == "1") {
            self.nombreTxt.text = self.cliente["razon_social"]
            self.cedulaTxt.text = self.cliente["ci_rif"]
            self.validarCliente.setTitle("EDITAR", for: .normal)
        }
        
        if (self.contribuyente["created"] == "1"){
            self.contribuyenteTxt.text = self.contribuyente["razon_social"]
            self.cedulaContribuyenteTxt.text = self.contribuyente["ci_rif"]
            self.validarContribuyente.setTitle("EDITAR", for: .normal)
        }
        
        // Desactivamos los inputs
        self.nombreTxt.isEnabled = false
        self.contribuyenteTxt.isEnabled = false
        self.cedulaContribuyenteTxt.isEnabled = false
        self.cedulaContribuyenteTxt.isEnabled = false
        self.contribuyentePicker.alpha = 0.5
        self.contribuyentePicker.isUserInteractionEnabled = false
        self.irAColaVirtualBtn.isEnabled = false
        self.irAColaVirtualBtn.isUserInteractionEnabled = false
        self.irAColaVirtualBtn.alpha = 0.5
        // Connect data PickerView
        self.contribuyentePicker.delegate = self
        self.contribuyentePicker.dataSource = self
        self.cedulaPicker.delegate = self
        self.cedulaPicker.dataSource = self
        
        // Cuando se hace TAP en cualquier lugar oculta el keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    // Verificamos si el cliente existe
    @IBAction func validarCedula(_ sender: Any) {
        // Cerramos el teclado
        dismissKeyboard()
        
        // Presentamos el loader
        ToolsPaseo().loadingView(vc: self, msg: "Buscando cliente...")

        // Cedula de identidad o R.I.F del comprador
        let tipoDocumento = String(self.identidadArray[self.cedulaPicker.selectedRow(inComponent: 0)])
        let documentoIdentidad = "\(tipoDocumento!)\(self.cedulaTxt.text!)"
        
        // Realizamos a consulta a la base de datos
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto, razon_social,ci_rif, dir_fiscal, celular, fecha_nacimiento FROM clientes WHERE ci_rif='\(documentoIdentidad)' and estatus='Activo'") { (data) in
            
            // Objeto con la informacion de los clientes
            self.cliente["auto"] = ToolsPaseo().obtenerDato(s: data, i: 0)
            self.cliente["razon_social"] = ToolsPaseo().obtenerDato(s: data, i: 1)
            self.cliente["ci_rif"] = ToolsPaseo().obtenerDato(s: data, i: 2)
            self.cliente["dir_fiscal"] = ToolsPaseo().obtenerDato(s: data, i: 3)
            self.cliente["celular"] = ToolsPaseo().obtenerDato(s: data, i: 4)
            self.cliente["fecha_nacimiento"] = ToolsPaseo().obtenerDato(s: data, i: 5)
            self.cliente["created"] = "1"
            
            // Busca la cuenta
            ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto FROM pos_cuentas WHERE cuenta='\(self.cliente["ci_rif"])'") { (data) in
                let auto_cuenta = ToolsPaseo().obtenerDato(s: data, i: 0)
                
                if (auto_cuenta == "") {
                    //ToolsPaseo().consultarDB(id: "open", sql: "", completion: <#T##(String) -> Void#>)
                    //CREAR CUENTA
                }
            }
            // Quitamos el loading y como callback lo que debe hacer
            self.dismiss(animated: false){
                if (self.cliente["auto"] == ""){
                    let alerta = UIAlertController(title: "El cliente no existe", message: "¿Desea crearlo?", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Si", style: UIAlertActionStyle.default, handler: { (action) in
                        /*
                         Si la opcion es 'SI' al cliente se habilian los campos
                         */
                        
                        // cambiamos la pantalla para registrar el cliente
                        self.performSegue(withIdentifier: "crearCliente", sender: self)
                        
                    }))
                    alerta.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alerta, animated: true, completion: nil)
                    
                    
                } else {
                    // si el cliente ya existe se ingresa la informacion a los inputs siguiendo deshabilitados
                    self.nombreTxt.text = self.cliente["razon_social"]
                    self.isReady = true
                    self.irAColaVirtualBtn.isEnabled = true
                    self.irAColaVirtualBtn.isUserInteractionEnabled = true
                    self.irAColaVirtualBtn.alpha = 1
                }
            }
        }
    }
    
    @IBAction func validarContribuyente(_ sender: Any) {
        
        // Cerramos el teclado
        dismissKeyboard()
        
        // Presentamos el loader
        ToolsPaseo().loadingView(vc: self, msg: "Buscando contribuyente...")
        
        // Cedula de identidad o R.I.F del comprador
        let tipoDocumento = String(self.contribuyenteArray[self.contribuyentePicker.selectedRow(inComponent: 0)])
        let documentoIdentidad = "\(tipoDocumento!)\(self.cedulaContribuyenteTxt.text!)"
        
        // Realizamos a consulta a la base de datos
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT auto, razon_social,ci_rif, dir_fiscal, celular, fecha_nacimiento FROM clientes WHERE ci_rif='\(documentoIdentidad)' and estatus='Activo'") { (data) in
            
            self.dismiss(animated:false){
                // Objeto con la informacion de los clientes
                self.contribuyente["auto"] = ToolsPaseo().obtenerDato(s: data, i: 0)
                self.contribuyente["razon_social"] = ToolsPaseo().obtenerDato(s: data, i: 1)
                self.contribuyente["ci_rif"] = ToolsPaseo().obtenerDato(s: data, i: 2)
                self.contribuyente["dir_fiscal"] = ToolsPaseo().obtenerDato(s: data, i: 3)
                self.contribuyente["celular"] = ToolsPaseo().obtenerDato(s: data, i: 4)
                self.contribuyente["fecha_nacimiento"] = ToolsPaseo().obtenerDato(s: data, i: 5)
                
                if (self.contribuyente["auto"] == ""){
                    let alerta = UIAlertController(title: "El contribuyente no existe", message: "¿Desea crearlo?", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Si", style: UIAlertActionStyle.default, handler: { action in
                        /*
                         Si la opcion es 'SI' al cliente se habilian los campos
                         */
                        self.performSegue(withIdentifier: "crearContribuyente", sender: self)
                    }))
                    alerta.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alerta, animated: true, completion: nil)
                } else {
                    // si el cliente ya existe se ingresa la informacion a los inputs siguiendo deshabilitados
                    self.contribuyenteTxt.text = self.contribuyente["razon_social"]
                    self.isReady = true
                    self.irAColaVirtualBtn.isEnabled = true
                    self.irAColaVirtualBtn.isUserInteractionEnabled = true
                    self.irAColaVirtualBtn.alpha = 1
                }
            }
        }
    }
    
    // Cuando envimaos a la cola
    @IBAction func enviarAColaVirtual(_ sender: Any) {
        // Loading
        ToolsPaseo().loadingView(vc: self, msg: "Cargando...")
        
        // Seccion a la cual se va a agregar a la cola virtual
        var seccion = ""
        if (isPanaderiaCheck == true){
            seccion = "04"
        } else if (isCharcuteriaCheck == true){
            seccion = "03"
        } else if (isPasteleriaCheck == true) {
            seccion = "06"
        }
        
        // Realizamos el insert a la DB
        ToolsPaseo().consultarDB(id: "open", sql: "INSERT INTO `00000001`.`pos_turno` (`id`, `seccion`, `cirif`, `nombre`, `estatus`) VALUES (NULL, '\(seccion)', '\(self.cliente["ci_rif"]!)', '\(self.cliente["razon_social"]!)', '0');") { (data) in
            
            // Quitamos el loading y como callback lo que debe hacer
            self.dismiss(animated:false){
                print("Data:'\(data)':END")
            }
        }
        
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
        
        if (pickerView == cedulaPicker){
            return identidadArray.count
        } else if(pickerView == contribuyentePicker) {
            return contribuyenteArray.count
        }
        
        return 1
    }
    
    // Seteamos los arreglos(data) a los picker
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        
        if (pickerView == contribuyentePicker){
            return contribuyenteArray[row]
        } else if (pickerView == cedulaPicker) {
            return identidadArray[row]
        }
        return ""
    }
    
    // Cuando seleciona la seccion panaderia
    @IBAction func clickPanaderiaCheck(_ sender: Any) {
        if (isPanaderiaCheck == false && isReady == true) {
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
        if (isPasteleriaCheck == false && isReady == true) {
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
        if (isCharcuteriaCheck == false && isReady == true) {
            charcuteriaCheck.backgroundColor = UIColor.green
            pasteleriaCheck.backgroundColor = UIColor.lightGray
            panaderiaCheck.backgroundColor = UIColor.lightGray
            isCharcuteriaCheck = true
            isPanaderiaCheck = false
            isPasteleriaCheck = false
        }
    }
    
    @IBAction func clickContribuyenteCheck(_ sender: Any) {
        if (self.isContribuyenteCheck == false && self.nombreTxt.text != ""){
            contribuyenteCheck.backgroundColor = UIColor.green
            self.isContribuyenteCheck = true
            self.cedulaContribuyenteTxt.isEnabled = true
            self.contribuyentePicker.alpha = 1
            self.contribuyentePicker.isUserInteractionEnabled = true
            self.isReady = false
        } else {
            contribuyenteCheck.backgroundColor = UIColor.lightGray
            isContribuyenteCheck = false
            self.cedulaContribuyenteTxt.isEnabled = false
            self.contribuyentePicker.alpha = 0.5
            self.contribuyentePicker.isUserInteractionEnabled = false
            self.isReady = true
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "crearCliente" {
            if let destination = segue.destination as? ViewController {
                destination.cedula = self.cedulaTxt.text!
                destination.tipoSegue = "crearCliente"
            }
        } else if segue.identifier == "crearContribuyente" {
            if let destination = segue.destination as? ViewController {
                destination.cedula = self.cedulaContribuyenteTxt.text!
                destination.cliente = self.cliente
                destination.tipoSegue = "crearContribuyente"
            }
        }
    }
    
}

