# DateCacher

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage) ![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat-square) ![platforms](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat-square) [![license](	https://img.shields.io/github/license/smolster/DateCacher.svg?style=flat-square)](https://github.com/smolster/DateCacher/blob/master/LICENSE)

A result-caching Date Formatter helper.



## Use Case

`DateCacher` uses result-caching to optimize formatting `String` objects from `Date` objects, and vice versa. This optimization is effective for apps that expect to display lots of dates across multiple formats.

## How to Implement

First, set up a `DateCacher` object. A simple approach: use a global cacher.

```swift
import DateCacher

private let sharedDateCacher = DateCacher()

extension DateCacher {
   var shared: DateCacher { return sharedDateCacher }
}
```

Next, you'll need a type to conform to the `DateFormat` `protocol`. We recommend using an `enum`.

```swift
enum MyFormat: DateCacher.DateFormat {
   case monthDayYear
   case monthDayYearHourMinute

   var formatString: String {
      switch self {
      case .monthDayYear:           return "MM-dd-yyyy"
      case .monthDayYearHourMinute: return "MM-dd-yyyy HH:mm"
      }
   }
   
   var components: Set<Calendar.Components> {
       switch self {
       case .monthDayYear:           return [.month, .day, .year]
       case .monthDayYearHourMinute: return [.month, .day, .year, .hour, .minute]
       }
   }
}
```

Next, route all of your date formatting through the cacher.

```swift
DateCacher.shared.date(from: "01-01-2001", using: MyFormat.monthDayYear) // -> Date?

DateCacher.shared.string(from: Date(), using MyFormat.monthDayYear) // -> "01-01-2001"
```
## Get it!
### Carthage
```
github 'smolster/DateCacher'
```
