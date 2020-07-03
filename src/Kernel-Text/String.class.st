Class {
	#name : #String,
	#superclass : #ArrayedCollection,
	#type : #bytes,
	#classVars : [
		'AsciiOrder',
		'CaseInsensitiveOrder',
		'CaseSensitiveOrder',
		'LowercasingTable',
		'UppercasingTable'
	],
	#category : #'Kernel-Text'
}

{ #category : #all }
String class >> cr [
	"Answer a string containing a carriage return character."

	^ self with: Character cr
]

{ #category : #all }
String class >> initialize [
	"self initialize"

	| order |
	AsciiOrder := (0 to: 255) asByteArray.
	CaseInsensitiveOrder := AsciiOrder copy.
	($a to: $z)
		do: [ :c | 
			CaseInsensitiveOrder
				at: c asciiValue + 1
				put: (CaseInsensitiveOrder at: c asUppercase asciiValue + 1) ].	"case-sensitive compare sorts space, digits, letters, all the rest..."
	CaseSensitiveOrder := (AsciiOrder collect: [ :x | 255 ]) asByteArray.
	order := -1.
	' 0123456789'
		do:
			[ :c | CaseSensitiveOrder at: c asciiValue + 1 put: (order := order + 1) ].
	"digits, 0-10"
	($a to: $z)
		do: [ :c | 
			CaseSensitiveOrder
				at: c asUppercase asciiValue + 1
				put: (order := order + 1).
			CaseSensitiveOrder at: c asciiValue + 1 put: (order := order + 1) ].
	"letters, 11-64"
	1 to: CaseSensitiveOrder size do: [ :i | 
		(CaseSensitiveOrder at: i) = 255
			ifTrue: [ CaseSensitiveOrder at: i put: (order := order + 1) ] ].
	"all other characters"
	order = 255
		ifFalse: [ self error: 'order problem' ].	"create a table for translating to lower case"
	LowercasingTable := ((0 to: 255)
		collect: [ :i | i asCharacter asLowercase ]) asString.
	UppercasingTable := ((0 to: 255)
		collect: [ :i | i asCharacter asUppercase ]) asString
]

{ #category : #all }
String >> < aString [
	"Answer whether the receiver sorts before aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) = 1
]

{ #category : #all }
String >> <= aString [
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) <= 2
]

{ #category : #all }
String >> = aString [
	"Answer whether the receiver sorts equally as aString.
	The collation order is simple ascii (with case differences)."

	aString species == String
		ifFalse: [ ^ false ].
	^ (self compare: self with: aString collated: AsciiOrder) = 2
]

{ #category : #all }
String >> > aString [
	"Answer whether the receiver sorts after aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) = 3
]

{ #category : #all }
String >> >= aString [
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) >= 2
]

{ #category : #all }
String >> asByteArray [
	"Answer a ByteArray containing the ASCII values of my characters. Uses a fast primitive that avoids character conversion."

	^ (ByteArray new: self size)
		replaceFrom: 1
		to: self size
		with: self
]

{ #category : #all }
String >> asUppercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	| result |
	result := self copy asString.
	self
		translate: result
		from: 1
		to: result size
		table: UppercasingTable.
	^ result
]

{ #category : #all }
String >> asLowercase [
	"Answer a String made up from the receiver whose characters are all lowercase."

	| result |
	result := self copy asString.
	self
		translate: result
		from: 1
		to: result size
		table: LowercasingTable.
	^ result
]

{ #category : #all }
String >> asString [
	"Answer this string."

	^ self
]

{ #category : #all }
String >> asSymbol [
	"This is the only place that new Symbols are created. A Symbol is created if and only if there is not already a Symbol with its contents in existance."

"
	Symbol
		allInstancesDo: [ :sym | 
			self = sym
				ifTrue: [ ^ sym ] ].
	^ (Symbol basicNew: self size) initFrom: self
"
	^Symbol fromString: self
]

{ #category : #all }
String >> at: index [
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	^ (super at: index) asCharacter
]

{ #category : #all }
String >> at: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 64>
	(aCharacter isKindOf: Character)
		ifTrue: [ index isInteger
				ifTrue: [ self errorSubscriptBounds: index ]
				ifFalse: [ self errorNonIntegerIndex ] ]
		ifFalse: [ self error: 'Strings only store Characters' ]
]

{ #category : #all }
String >> compare: aString [
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	The collation sequence is ascii with case differences ignored.
	To get the effect of a <= b, but ignoring case, use (a compare: b) <= 2."

	^ self compare: self with: aString collated: CaseInsensitiveOrder
]

{ #category : #all }
String >> compare: string1 with: string2 collated: order [
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	<primitive: 'primitiveCompareString' module: 'MiscPrimitivePlugin'>
	| len1 len2 c1 c2 |
	len1 := string1 size.
	len2 := string2 size.
	1 to: (len1 min: len2) do: [ :i | 
		c1 := order at: (string1 basicAt: i) + 1.
		c2 := order at: (string2 basicAt: i) + 1.
		c1 = c2
			ifFalse: [ c1 < c2
					ifTrue: [ ^ 1 ]
					ifFalse: [ ^ 3 ] ] ].
	len1 = len2
		ifTrue: [ ^ 2 ].
	len1 < len2
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^ 3 ]
]

{ #category : #all }
String >> findDelimiters: delimiters startingAt: start [
	"Answer the index of the character within the receiver, starting at start, that matches one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1."

	start to: self size do: [ :i | 
		delimiters
			do: [ :delim | 
				delim = (self at: i)
					ifTrue: [ ^ i ] ] ].
	^ self size + 1
]

{ #category : #all }
String >> findString: key startingAt: start caseSensitive: caseSensitive [
	"Answer the index in this String at which the substring key first occurs at or after the given starting index. The match can be case-sensitive or not. Answer zero if no match is found."

	^ self
		findSubstring: key
		in: self
		startingAt: start
		matchTable:
			(caseSensitive
				ifTrue: [ CaseSensitiveOrder ]
				ifFalse: [ CaseInsensitiveOrder ])
]

{ #category : #all }
String >> findSubstring: key in: body startingAt: start matchTable: matchTable [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start. The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches. If no match is found, zero will be returned."

	"Note: The algorithm below is not optimum because it is intended to be translated to C."

	<primitive: 'primitiveFindSubstring' module: 'MiscPrimitivePlugin'>
	| index |
	key size = 0
		ifTrue: [ ^ 0 ].
	start to: body size - key size + 1 do: [ :startIndex | 
		index := 1.
		[ (matchTable at: (body at: startIndex + index - 1) asciiValue + 1)
			= (matchTable at: (key at: index) asciiValue + 1) ]
			whileTrue: [ index = key size
					ifTrue: [ ^ startIndex ].
				index := index + 1 ] ].
	^ 0	"
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 1 matchTable: CaseSensitiveOrder 1
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 2 matchTable: CaseSensitiveOrder 7
' ' findSubstring: 'abc' in: 'abcdefabcd' startingAt: 8 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseSensitiveOrder 0
' ' findSubstring: 'abc' in: 'abcdefABcd' startingAt: 2 matchTable: CaseInsensitiveOrder 7
"
]

{ #category : #all }
String >> findTokens: delimiters [
	"Answer the collection of tokens that result from parsing self. Any character in the String delimiters marks a border. Several delimiters in a row are considered as just one separation."

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[ keyStop <= self size ]
		whileTrue: [ keyStart := self skipDelimiters: delimiters startingAt: keyStop.
			keyStop := self findDelimiters: delimiters startingAt: keyStart.
			keyStart < keyStop
				ifTrue: [ tokens add: (self copyFrom: keyStart to: keyStop - 1) ] ].
	^ tokens
]

{ #category : #all }
String >> hash [
	| l m |
	(l := m := self size) <= 2
		ifTrue: [ l = 2
				ifTrue: [ m := 3 ]
				ifFalse: [ l = 1
						ifTrue: [ ^ ((self at: 1) asciiValue bitAnd: 127) * 106 ].
					^ 21845 ] ].
	^ (self at: 1) asciiValue * 48 + ((self at: m - 1) asciiValue + l)
]

{ #category : #all }
String >> indexOf: aCharacter startingAt: start [
	^ self
		indexOfAscii: aCharacter asciiValue
		inString: self
		startingAt: start
]

{ #category : #all }
String >> indexOf: aCharacter startingAt: startIndex ifAbsent: absentBlock [
	"Answer the index of the given Character within me starting the search at the given index. If I do not contain the Character, answer the result of evaluating the given block."

	| ans |
	ans := self
		indexOfAscii: aCharacter asciiValue
		inString: self
		startingAt: startIndex.
	ans = 0
		ifTrue: [ ^ absentBlock value ]
		ifFalse: [ ^ ans ]
]

{ #category : #all }
String >> indexOfAscii: anInteger inString: aString startingAt: start [

	<primitive: 'primitiveIndexOfAsciiInString' module: 'MiscPrimitivePlugin'>
	| stringSize |
	stringSize := aString size.
	start to: stringSize do: [ :pos | 
		(aString basicAt: pos) = anInteger
			ifTrue: [ ^ pos ] ].
	^ 0
]

{ #category : #all }
String >> numArgs [
	"Answer the number of arguments that the receiver would take considered as a selector or -1 if it couldn't be a selector."

	| firstChar numColons |
	firstChar := self at: 1.
	firstChar isLetter
		ifTrue: [ numColons := 0.
			self
				do: [ :ch | 
					ch tokenish
						ifFalse: [ ^ -1 ].
					ch = $:
						ifTrue: [ numColons := numColons + 1 ] ].
			numColons > 0 & (self last ~= $:)
				ifTrue: [ ^ -1 ].
			^ numColons ].
	firstChar isSpecial
		ifTrue: [ self size = 1
				ifTrue: [ ^ 1 ].
			(self size = 2 and: [ (self at: 2) isSpecial ])
				ifTrue: [ ^ 1 ].
			^ -1 ].
	^ -1
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
String >> skipDelimiters: delimiters startingAt: start [
	"Answer the index of the first character in this string starting at the given index that does NOT match one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1. Assumes the delimiters to be a non-empty string."

	start to: self size do: [ :i | 
		(delimiters indexOf: (self at: i) startingAt: 1) = 0
			ifTrue: [ ^ i ] ].
	^ self size + 1
]

{ #category : #all }
String >> substrings [
	^ self findTokens: ' '
]

{ #category : #all }
String >> translate: aString from: start to: stop table: table [
	"Translate the characters in the given string in place using the given mapping table."

	<primitive: 'primitiveTranslateStringWithTable' module: 'MiscPrimitivePlugin'>
	start to: stop do: [ :i | aString at: i put: (table at: (aString at: i) asciiValue + 1) ]
]

{ #category : #all }
String >> isString [
	^ true
]

{ #category : #all }
String >> cpEncodeWith: anEncoder [
	anEncoder encodeString: self
]
