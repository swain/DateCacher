//
//  DateCacher.swift
//  DateCacher
//
//  Created by Swain Molster on 7/3/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

public protocol DateFormat {
    var formatString: String { get }
    var components: Set<Calendar.Component> { get }
}

open class DateCacher {
    
    public typealias FormatterCache = [String: DateFormatter]
    public typealias ResultCache = [String: (stringCache: [Date: String], dateCache: [String: Date])]
    
    /// Keys are date format strings.
    internal private(set) var formatterCache: FormatterCache = [:]
    internal private(set) var resultCache: ResultCache = [:]
    
    private let calendar: Calendar?
    
    public init(calendar: Calendar? = .current) {
        self.calendar = calendar
    }
    
    open func date(from string: String, using format: DateFormat) -> Date? {
        if let cachedResult = resultCache[format.formatString]?.dateCache[string] {
            return cachedResult
        }

        guard let date = formatter(for: format).date(from: string) else {
            return nil
        }
        
        let dateToReturn = simplifiedDate(for: date, using: format) ?? date
        cache((string, dateToReturn), for: format)
        
        return dateToReturn
    }
    
    open func string(from date: Date, using format: DateFormat) -> String {
        
        let date = simplifiedDate(for: date, using: format) ?? date
        
        if let cachedResult = resultCache[format.formatString]?.stringCache[date] {
            return cachedResult
        }
        
        let string = formatter(for: format).string(from: date)
        cache((string, date), for: format)
        return string
    }
    
    internal func formatter(for format: DateFormat) -> DateFormatter {
        if formatterCache[format.formatString] == nil {
            formatterCache[format.formatString] = DateFormatter(formatString: format.formatString)
        }
        return formatterCache[format.formatString]!
    }
    
    internal func simplifiedDate(for date: Date, using format: DateFormat) -> Date? {
        guard let calendar = calendar else { return nil }
        let dateComponents = calendar.dateComponents(format.components, from: date)
        return calendar.date(from: dateComponents)
    }
    
    internal func cache(_ pair: (string: String, date: Date), for format: DateFormat) {
        if resultCache[format.formatString] == nil {
            resultCache[format.formatString] = ([:], [:])
        }
        resultCache[format.formatString]!.dateCache[pair.string] = pair.date
        resultCache[format.formatString]!.stringCache[pair.date] = pair.string
    }
}

private extension DateFormatter {
    convenience init(formatString: String) {
        self.init()
        self.dateFormat = formatString
    }
}
