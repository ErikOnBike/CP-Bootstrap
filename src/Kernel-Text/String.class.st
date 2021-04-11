Class {
	#name : #String,
	#superclass : #ArrayedCollection,
	#category : #'Kernel-Text'
}

{ #category : #all }
String class >> new: sizeRequested [
	"Return an instance with the number of indexable variables specified by the argument"

	^ self == String
		ifTrue:[ ByteString new: sizeRequested ]
		ifFalse:[ self basicNew: sizeRequested ]
]

{ #category : #all }
String class >> fromWordArray: aWordArray [

	<primitive: 'primitiveStringFromWordArray:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String class >> cr [
	"Answer a string containing a carriage return character"

	^ self with: Character cr
]

{ #category : #all }
String class >> lf [
	"Answer a string containing a linefeed character"

	^ self with: Character lf
]

{ #category : #all }
String class >> with: aCharacter [
	"Answer a string containing the specified character"

	^ aCharacter asInteger < 256
		ifTrue: [ ByteString with: aCharacter ]
		ifFalse: [ WideString with: aCharacter ]
]

{ #category : #all }
String >> < aString [
	"Answer whether the receiver sorts before aString.
	The collation order is simple ascii (with case differences)."

	^ (self asciiCompare: aString) = 1
]

{ #category : #all }
String >> <= aString [
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self asciiCompare: aString) <= 2
]

{ #category : #all }
String >> = aString [
	"Answer whether the receiver sorts equally as aString.
	The collation order is simple ascii (with case differences)."

	^ (self asciiCompare: aString) = 2
]

{ #category : #all }
String >> > aString [
	"Answer whether the receiver sorts after aString.
	The collation order is simple ascii (with case differences)."

	^ (self asciiCompare: aString) = 3
]

{ #category : #all }
String >> >= aString [
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self asciiCompare: aString) >= 2
]

{ #category : #all }
String >> asciiCompare: aString [

	<primitive: 'primitiveStringAsciiCompare:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> asUppercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	<primitive: 'primitiveStringAsUppercase' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> asLowercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	<primitive: 'primitiveStringAsLowercase' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> asString [
	"Answer this string."

	^ self
]

{ #category : #all }
String >> at: index [
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	self primitiveFailed
]

{ #category : #all }
String >> at: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 64>
	self primitiveFailed
]

{ #category : #all }
String >> isString [
	^ true
]

{ #category : #all }
String >> includesSubstring: aString [

	<primitive: 'primitiveStringIncludesSubstring:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> findTokens: delimiters [
	"Answer the collection of tokens that result from parsing self. Any character in the String delimiters marks a border. Several delimiters in a row are considered as just one separation.
	The specified delimiters can also be a Character."

	^ OrderedCollection withAll: (delimiters isString
		ifTrue: [ self primFindTokens: delimiters ]
		ifFalse: [ self primFindTokens: (WideString with: delimiters) ])
]

{ #category : #all }
String >> primFindTokens: delimiters [

	<primitive: 'primitiveStringFindTokens:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> substrings [
	^ self findTokens: ' '
]

{ #category : #all }
String >> printOn: aStream [
	"Print inside string quotes, doubling inbedded quotes."

	| x |
	aStream nextPut: $'.
	1 to: self size do: [ :i | 
		aStream nextPut: (x := self at: i).
		x == $'
			ifTrue: [ aStream nextPut: x ] ].
	aStream nextPut: $'
]

{ #category : #all }
String >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super
		replaceFrom: start
		to: stop
		with: replacement
		startingAt: repStart
]

{ #category : #all }
String >> size [
	"Primitive. Answer the number of indexable fields in the receiver. This
	value is the same as the largest legal subscript. Essential. See Object
	documentation whatIsAPrimitive."

	<primitive: 62>
	^ self basicSize
]

{ #category : #all }
String >> truncateTo: smallSize [
	"return myself or a copy shortened to smallSize."

	^ self size <= smallSize
		ifTrue: [ self ]
		ifFalse: [ self copyFrom: 1 to: smallSize ]
]

{ #category : #all }
String >> hash [

	<primitive: 'primitiveStringHash' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> cpEncodeWith: anEncoder [
	anEncoder encodeString: self
]
