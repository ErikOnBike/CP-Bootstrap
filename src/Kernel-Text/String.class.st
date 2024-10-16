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
	^ ((aCharacter asInteger < 256 ifTrue: [ ByteString ] ifFalse: [ WideString ]) new: 1)
		at: 1 put: aCharacter ;
		yourself
]

{ #category : #all }
String >> , aString [
	"Answer a new String consisting of the receiver
	concatenated with the specified String"

	<primitive: 'primitiveStringConcatenate:' module: 'CpSystemPlugin'>
	^ super , aString
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
String >> capitalized [
	"Return a copy with the first letter capitalized"
	| cap |
	self ifEmpty: [ ^ self copy ].
	cap := self copy.
	cap at: 1 put: (cap at: 1) asUppercase.
	^ cap
]

{ #category : #all }
String >> uncapitalized [
	"Return a copy with the first letter uncapitalized"
	| uncap |
	self ifEmpty: [ ^ self copy ].
	uncap := self copy.
	uncap at: 1 put: (uncap at: 1) asLowercase.
	^ uncap
]

{ #category : #all }
String >> asString [
	"Answer this string."

	^ self
]

{ #category : #all }
String >> asNumber [
	"Answer the Number created by interpreting the receiver as the string 
	representation of a number"

	<primitive: 'primitiveStringAsNumber' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> asNumberOrNil [
	"Answer the Number created by interpreting the receiver as the string 
	representation of a number"

	<primitive: 'primitiveStringAsNumber' module: 'CpSystemPlugin'>
	^ nil
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
String >> indexOf: aCharacter [

	<primitive: 'primitiveStringIndexOf:' module: 'CpSystemPlugin'>
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
String >> withoutPrefix: prefix [
	"Remove the given prefix, if present."

	^ (self beginsWith: prefix)
		ifTrue: [ self copyFrom: 1 + prefix size to: self size ]
		ifFalse: [ self ]
]

{ #category : #all }
String >> withoutSuffix: suffix [
	"Remove the given suffix, if present."

	^ (self endsWith: suffix)
		ifTrue: [ self copyFrom: 1 to: self size - suffix size ]
		ifFalse: [ self ]
]

{ #category : #all }
String >> format: aCollection [
	"Format the receiver by interpolating elements from collection, as in the following examples:"
	"('Five is {1}.' format: { 1 + 4}) >>> 'Five is 5.'"
	"('Five is {five}.' format: (Dictionary with: #five -> 5)) >>>  'Five is 5.'"
	"('In {1} you can escape \{ by prefixing it with \\' format: {'strings'}) >>> 'In strings you can escape { by prefixing it with \' "
	"('In \{1} you can escape \{ by prefixing it with \\' format: {'strings'}) >>> 'In {1} you can escape { by prefixing it with \' "

	^ self class
		new: self size
		streamContents: [ :result |
			| stream |
			stream := self readStream.
			[ stream atEnd ]
				whileFalse: [ | currentChar |
					(currentChar := stream next) == ${
						ifTrue: [ | expression index |
							expression := stream upTo: $}.
							index := expression asNumberOrNil ifNil: [ expression ].
							result nextPutAll: (aCollection at: index) asString ]
						ifFalse: [ currentChar == $\
								ifTrue: [ stream atEnd
										ifFalse: [ result nextPut: stream next ] ]
								ifFalse: [ result nextPut: currentChar ] ] ] ]
]

{ #category : #all }
String >> join: aCollection [
	| seenFirst |
	seenFirst := false.
	^ String streamContents: [ :stream |
		aCollection do: [ :each |
			seenFirst
				ifTrue: [ stream nextPutAll: self ]
				ifFalse: [ seenFirst := true ].
			stream nextPutAll: each asString ] ]
]

{ #category : #all }
String >> hash [

	<primitive: 'primitiveStringHash' module: 'CpSystemPlugin'>
	^ self identityHash
]

{ #category : #all }
String >> trim [

	<primitive: 'primitiveStringTrim' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> trimLeft [

	<primitive: 'primitiveStringTrimLeft' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> trimRight [

	<primitive: 'primitiveStringTrimRight' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
String >> cpEncodeWith: anEncoder [
	anEncoder encodeString: self
]
