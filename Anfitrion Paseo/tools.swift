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
        
        Alamofire.request("http://10.10.8.27:8080/webserver.php/", method: .post, parameters:params, encoding: URLEncoding.default).response { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                dataDone = utf8Text
                completion(dataDone)
            }
        }
    }

}
