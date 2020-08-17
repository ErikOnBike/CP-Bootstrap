# Source code for tiny Smalltalk image

This repo contains the source code of the tiny Smalltalk image used in [CodeParadise](https://github.com/ErikOnBike/CodeParadise). The code is based on [Pharo Candle](https://github.com/carolahp/PharoCandleSrc). The image is created using [Pharo Bootstrap](https://github.com/carolahp/pharo). Easiest is to use the [Pharo Bootstrap Manager](https://github.com/carolahp/PBManager).

## Differences wrt Pharo Candle

This source code is based on Pharo Candle. The most relevant changes:
* All class names are changed to reflect regular class names (ie removed the PC prefix)
* Added Exception handling (classes Exception, Error, MessageNotUnderstood and the Block>>#on:do:, Context>>#unwindTo:, etc)
* Added Announcements (classes Announcer, Announcement, AnnouncementSubscription and SubscriptionRegistry)
* Added class Mutex
* Added SystemDictionary (empty subclass of Dictionary to allow SqueakJS VM to recognize the Smalltalk globals)
* Removed some classes (PCFile, PCBitBlt, PCForm, PCWordArray)
* Removed some test and benchmark code
* Reorganised some of the package structure
* Changed bits and pieces to allow the resulting image to be more compatible with regular Pharo/Cuis image

All added Classes are 'minimal' to keep the image tiny.

Furthermore a set of classes is added to create a `ClientEnvironment` which allows to communicate with a `ServerEnvironment` using WebSockets. This code is based on the knowledge that this tiny image will be run in a Javascript environment (using SqueakJS VM). For further explanation go to [CodeParadise](https://github.com/ErikOnBike/CodeParadise).

## Creating your own image

To create a tiny image yourself, you might have to use [PBManager](https://github.com/ErikOnBike/PBManager) because this tiny image uses a different language definition than the Pharo Candle source code (amongst others, due to the changed class names). The PR for my changes is being integrated, but might not have been done yet.

The following code can be executed to create the resulting image, without the need to use the GUI:
```Smalltalk
| repository builder |

repository := PBRepository fromLangFile: '/path/to/source-code/definition.lang' asFileReference.
builder := PBBuilder new pbRepository: repository ; yourself.
builder pbRepository pbBootstrapper bootstrap.            "generate the image in memory"
builder writeImageNamed: '/path/to/resulting/tiny.image'. "write the generated image to disk"
```

## To Do

There are still things missing from the tiny image, which will probably be added in the image itself. Although the ClientEnvironment is capable of installing code dynamically, it is probably easier to install it in the image by default. When installing for example the Duration or Fraction class from a Pharo or Cuis image into the tiny image, all methods for these classes will be installed. This brings a huge overhead since many methods are not necessary in the tiny image. The current Number classes inside the tiny image also have a limited amount of methods installed by default. It is possible to add individual methods dynamically, but not partial classes (at the moment).

Classes to add (probably):
* Duration
* Fraction
* ScaledDecimal
* Time
* Delay

Classes to add (maybe):
* Date
* DateAndTime
* Timespan
* TimeZone

Classes which will probably not be added (but fall in the same category):
* Week
* Month
* Year
* Schedule

This later list of classes is probably used mostly in business logic, more than in interface logic. The current/main use of the tiny image is to provide a user interface for WebApplications. Current design principle is: there should not be business logic executing inside the user interface.
