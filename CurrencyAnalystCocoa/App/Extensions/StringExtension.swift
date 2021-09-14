//
//  StringExtension.swift
//  CurrencyAnalyst
//
//  Created by denis on 04.06.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

extension String {
    func caseInsensitiveHasPrefix(_ prefix: String) -> Bool {
        return lowercased().hasPrefix(prefix.lowercased())
    }
    
    func isEmptyOrWhitespace() -> Bool {
        if(self.isEmpty) {
            return true
        }
        return (self.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")
    }
    
    func trimming() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func toSiteURL() -> URL? {
        if self.isEmptyOrWhitespace() {
            return nil;
        }
        
        if self.lowercased().starts(with: "https:") {
            return URL(string: self)
        }
        
        return URL(string: self, relativeTo: URL(string: Constants.Urls.sourceSiteUrl) )!
    }
    
}

