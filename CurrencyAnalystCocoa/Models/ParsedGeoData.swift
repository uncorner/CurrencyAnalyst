//
//  ParsedGeoData.swift
//  CurrencyAnalyst
//
//  Created by denis on 18.05.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

struct ParsedGeoData : Decodable {
    var values : [[Any]]
    
    enum CodingKeys : String, CodingKey {
        case values
    }
    
    init(from decoder: Decoder) throws {
        // get the dictionary
        let con = try! decoder.container(keyedBy: CodingKeys.self)
        // get the "values" array of array
        var con2 = try! con.nestedUnkeyedContainer(forKey: CodingKeys.values)
        var bigarr = [[Any]]()
        for _ in 0..<con2.count! {
            // get a nested array
            var con3 = try! con2.nestedUnkeyedContainer()
            // decode all the elements of the nested array
            var arr = [Any]()
            
            arr.append(try! con3.decode( Int.self ))
            arr.append(try! con3.decode( [Double].self ))
            arr.append(try! con3.decode( String.self ))
            
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode(Int.self))
            arr.append(try! con3.decode(Int.self))
            arr.append(try! con3.decode(Int.self))
            arr.append(try! con3.decode(Int.self))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode( String.self ))
            arr.append(try! con3.decode(Int.self))
            arr.append(try! con3.decode(Int.self))
            arr.append(try! con3.decode( String.self ))
            
            bigarr.append(arr)
        }
        // all done! finish initialization
        self.values = bigarr
    }
}
