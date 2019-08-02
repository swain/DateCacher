//
//  DateCacher.swift
//  DateCacher
//
//  Created by Swain Molster on 7/3/18.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

public protocol DateFormat {
    var formatString: String { get }
    var components: Set<Calendar.Component> { get }
}

open class DateCacher {
    
    internal typealias FormatterCache = [String: DateFormatter]
    internal typealias ResultCache = [String: (stringCache: [Date: String], dateCache: [String: Date])]
    
    /**
     Cache holding already-configured `DateFormatter` objects.
     
     Keys are date format strings. Values are `DateFormatter` objects configured for the format key.
     */
    internal private(set) var formatterCache: FormatterCache = [:]
    
    /**
     Cache holding already-constructed `String`/`Date` pairs, organized according to their format strings.
     
     Keys are date format strings. Values are a pair of mirrored `String`/`Date` caches, one keyed by `String`s, the other by `Date`s, for easy access using either object.
     
     _Example Usage_
     ```
     resultCache["MM-dd-yyyy"]?.dateCache["01-01-2001"] // -> Date?
     ```
     */
    internal private(set) var resultCache: ResultCache = [:]
    
    private let calendar: Calendar
    
    /**
     Creates a `DateCacher` using the provided `Calendar`. Default is `Calendar.current`.
     */
    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    /**
     Returns a `Date` object created from the given `string` and `format`, or `nil` if the `string` is not formatted correctly.
     
     - Parameters:
       - string: The date string. Should be formatted according to the provided `DateFormat`.
       - format: The expected format of the provided date `string`.
     
     This function relies on result caching to optimize it's efficiency.
     */
    open func date(from string: String, using format: DateFormat) -> Date? {
        // Check for a cached result keyed by the provided `string`. If available, return it.
        if let cachedResult = resultCache[format.formatString]?.dateCache[string] {
            return cachedResult
        }

        // Grab a `DateFormatter` for the provided `format`, and use it to make a `Date`.
        guard let date = formatter(for: format).date(from: string) else {
            // If this goes wrong, it's likely the `string`/`format` pair is not matched correctly. We return `nil`.
            return nil
        }
        
        // Try to simplify the `Date`. See explanation below in `string(date:format:)`.
        let dateToReturn = simplifiedDate(for: date, using: format) ?? date
        
        // Store the simplified date.
        cache((string, dateToReturn), for: format)
        
        return dateToReturn
    }
    
    /**
     Returns a `String` object created from the given `date` and `format`.
     
     - Parameters:
       - date: The Date object.
       - format: The expected format of the provided date `string`.
     
     This function relies on result caching to optimize it's efficiency.
     */
    open func string(from date: Date, using format: DateFormat) -> String {
        
        // Try to simplify the `date`. We don't want to store any components that aren't relevant
        // to the provided `DateFormat`. Storing non-relevant components could lead to redundant entries
        // in the result cache.
        //
        // For example, our `DateFormat` string may be "MM-dd-yyyy", but the provided `Date` may contain
        // information regarding hours or minutes. We want to strip this information from the `Date` object,
        // so as to only include a single entry for a given "MM-dd-yyyy".
        //
        let date = simplifiedDate(for: date, using: format) ?? date
        
        // Check for a cached result keyed by the provided (and simplified) `date`. If available, return it.
        if let cachedResult = resultCache[format.formatString]?.stringCache[date] {
            return cachedResult
        }
        
        // Otherwise, create a new formatted `String` and cache it.
        let string = formatter(for: format).string(from: date)
        cache((string, date), for: format)
        return string
    }
    
    /**
     Returns a `DateFormatter` object configured for the provided `format`, pulling from the formatter cache if possible.
     
     - parameter format: The desired configuration format.
     
     */
    internal func formatter(for format: DateFormat) -> DateFormatter {
        if formatterCache[format.formatString] == nil {
            formatterCache[format.formatString] = DateFormatter(formatString: format.formatString)
        }
        return formatterCache[format.formatString]!
    }
    
    /**
     Returns a simplified version of the provided `date`, or `nil` if a simplified `Date` could not be constructed. Specifically, returns a new `Date` constructed _only_ from the `DateComponents` relevant to the provided `format`.
     
     - Parameters:
       - date: The `Date` to simplify.
       - format: The desired `DateFormat`.
     */
    internal func simplifiedDate(for date: Date, using format: DateFormat) -> Date? {
        let dateComponents = self.calendar.dateComponents(format.components, from: date)
        
        if let newDate = self.calendar.date(from: dateComponents) {
            return newDate
        } else {
            return nil
        }
    }
    
    /**
     Stores the provided string/date `pair` into the cache.
     
     - Parameters:
       - pair: The `String`/`Date` pair to store.
       - format: The `DateFormat` of the provided `String`/`Date` pair.
     */
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
