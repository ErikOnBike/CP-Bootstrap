# Source code for tiny Smalltalk image

This repo contains the source code of the tiny Smalltalk image used in [CodeParadise](https://github.com/ErikOnBike/CodeParadise). The code is based on [Pharo Candle](https://github.com/carolahp/PharoCandleSrc). The image is created using [Tiny Bootstrap](https://github.com/ErikOnBike/TinyBootstrap).

Execute the following script to create the tiny image:
```bash
git clone https://github.com/ErikOnBike/TinyBootstrap tiny-bootstrap
git clone https://github.com/ErikOnBike/CP-Bootstrap bootstrap
mkdir work
cd work
../tiny-bootstrap/tiny-bootstrap -a 32 -s ../bootstrap/src -t client-environment.image -c "Smalltalk startUp: 'Tiny Image `date \"+%Y-%m-%d %H:%M:%S\"`'"
ls -l client-environment.image
```

## Image content

All Classes in the tiny image are 'minimal' to keep the image tiny in size. Furthermore a set of classes is added to create a `ClientEnvironment` which allows to communicate with a `ServerEnvironment` using WebSockets. This code is based on the knowledge that this tiny image will be run in a Javascript environment (using SqueakJS VM). For further explanation go to [CodeParadise](https://github.com/ErikOnBike/CodeParadise).

There are still things missing from the tiny image, which might be added in the image itself. Although the ClientEnvironment is capable of installing code dynamically, it is probably easier to install it in the image by default. When installing for example the Duration or Fraction class from a Pharo or Cuis image into the tiny image, all methods for these classes will be installed. This brings a huge overhead since many methods are not necessary in the tiny image. The current Number classes inside the tiny image also have a limited amount of methods installed by default. It is possible to add individual methods dynamically, but not partial classes (at the moment).

Classes to add (maybe):
* Duration
* Fraction
* ScaledDecimal
* Time
* Delay
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

## Differences wrt Pharo Candle

This source code is based on Pharo Candle. The most relevant changes:
* All class names are changed to reflect regular class names (ie removed the PC prefix)
* Added Exception handling (classes Exception, Error, MessageNotUnderstood and the Block>>#on:do:, Context>>#unwindTo:, etc)
* Added Announcements (classes Announcer, Announcement, AnnouncementSubscription and SubscriptionRegistry)
* Added class Mutex
* Added SystemDictionary (empty subclass of Dictionary to allow SqueakJS VM to recognize the Smalltalk globals)
* Moved all System class behavior to SmalltalkImage and removed System class
* Removed some classes (PCFile, PCBitBlt, PCForm, PCWordArray)
* Removed some test and benchmark code
* Reorganised some of the package structure
* Changed bits and pieces to allow the resulting image to be more compatible with regular Pharo/Cuis image
