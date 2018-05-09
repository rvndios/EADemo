//
//  Extensions.swift
//  EADemo
//
//  Created by Farhad Rismanchian on 10/12/16.
//
//

import Foundation


extension String {
    
    func dataFromHexString() -> Data? {
        
        guard let chars = cString(using: String.Encoding.utf8) else { return nil}
        let length = count
        guard let data = NSMutableData(capacity: length/2) else { return nil }
        var byteChars: [CChar] = [0, 0, 0]
        var wholeByte: CUnsignedLong = 0
        
        for i in stride(from: 0, to: length, by: 2) {
            byteChars[0] = chars[i]
            byteChars[1] = chars[i + 1]
            wholeByte = strtoul(byteChars, nil, 16)
            data.append(&wholeByte, length: 1)
        }
        return data as Data
    }
    
    
    init?(hexadecimalString: String) {
        guard let data = hexadecimalString.dataFromHexString() else {
            return nil
        }
        
        self.init(data: data, encoding: String.Encoding.utf8)
    }
    
    
    func hexadecimalString() -> String? {
        return data(using: String.Encoding.utf8)?.hexEncodedString()
    }
}



extension String.Index{
    
    func successor(in string:String)->String.Index{
        return string.index(after: self)
    }
    
    
    func predecessor(in string:String)->String.Index{
        return string.index(before: self)
    }
    
    
    func advance(_ offset:Int, `for` string:String)->String.Index{
        return string.index(self, offsetBy: offset)
    }
}


extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
