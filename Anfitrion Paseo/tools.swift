//
//  tools.swift
//  Anfitrion Paseo
//
//  Created by Macbook on 26/10/17.
//  Copyright © 2017 Grupo Paseo. All rights reserved.
//

import Foundation
import Alamofire

class ToolsPaseo {

    func obtenerDato(s: String, i: Int) -> String {
        var r: String = ""
        var l: Int = 0
        var ct: Int = 0
        var ch: Character
        
        while ( (l<s.characters.count) && (ct<=i)) {
            let index = s.index(s.startIndex, offsetBy: l)
            ch = s[index]
            
            if(ch=="\t") {
                ct+=1
                if(ct<=i) {
                    r = ""
                }
            } else {
                r = r + String(ch)
            }
            l+=1
        }
        return r.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func consultarDB(id:String, sql:String, completion:@escaping (String) -> Void){
        let params = [
            "id":id,
            "sql":sql
        ]
        
        var dataDone: String = ""
        
        Alamofire.request("http://10.10.0.199:8083/webserver.php/", method: .post, parameters:params, encoding: URLEncoding.default).response { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                dataDone = utf8Text
                completion(dataDone)
            }
        }
    }
    
    func loadingView(vc: UIViewController, msg: String){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    func crearCuenta(ci_rif: String){
        // Crear cuenta y actualizar contadores
        ToolsPaseo().consultarDB(id: "open", sql: "SELECT a_pos_cuentas FROM sistema_contadores limit 1"){ data in
            let auto = Int(ToolsPaseo().obtenerDato(s: data, i: 0))!
            let auto_nuevo = auto + 1
            let auto_cuentas = String(format: "%010d", auto_nuevo)
            
            // Si no existe la cuenta se crea
            ToolsPaseo().consultarDB(id: "open", sql: "INSERT INTO `00000001`.`pos_cuentas` (`auto`, `cuenta`, `estatus_cuenta`, `estatus_servicio`, `estatus_abierta`, `estatus`, `acumulado`, `auto_cliente`, `ci_rif`, `nombre`, `dir_fiscal`, `hora`, `fin`, `corte`) VALUES ('\(auto_cuentas)', '\(ci_rif)', '0', '0', '0', 'Activo', '0.00', '', '', '', '', '', '', '0')") { (data) in
                
                // Verificamos si no existe algun error
                if data.range(of:"Error") == nil {
                    ToolsPaseo().consultarDB(id: "open", sql: "UPDATE `00000001`.`sistema_contadores` SET `a_pos_cuentas` = '\(auto_nuevo)' WHERE a_pos_cuentas != '' LIMIT 1"){(data) in}
                }
            }
        }
    }
}
