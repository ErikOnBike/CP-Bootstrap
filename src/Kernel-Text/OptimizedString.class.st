Class {
	#name : #OptimizedString,
	#superclass : #ArrayedCollection,
	#category : #'Kernel-Text'
}

{ #category : #all }
OptimizedString class >> install [
	<primitive: 'primitiveOptimizedStringInstall' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString class >> new: anInteger [
	<primitive: 'primitiveOptimizedStringNew:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString class >> stringHash: aString initialHash: speciesHash [
	<primitive: 'primitiveOptimizedStringStringHash:initialHash:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString class >> fromByteString: aByteString [
	<primitive: 'primitiveOptimizedStringNewFromByteString:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> initialize [
	super initialize.
	self primInitialize.
]

{ #category : #all }
OptimizedString >> primInitialize [
	<primitive: 'primitiveOptimizedStringInitialize' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> , aString [
	"Answer a new String composed of the receiver concatenated with aString"

	<primitive: 'primitiveOptimizedStringConcatenate:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> < aString [
	"Answer whether the receiver sorts before aString.
	Use default collation order (with case differences)."

	^ (self compareWith: aString collated: nil) = 1
]

{ #category : #all }
OptimizedString >> <= aString [
	"Answer whether the receiver sorts before or equal to aString.
	Use default collation order (with case differences)."

	^ (self compareWith: aString collated: nil) <= 2
]

{ #category : #all }
OptimizedString >> = aString [
	"Answer whether the receiver sorts equally as aString.
	Use default collation order (with case differences)."

	aString species == OptimizedString
		ifFalse: [ ^ false ].
	^ (self compareWith: aString collated: nil) = 2
]

{ #category : #all }
OptimizedString >> > aString [
	"Answer whether the receiver sorts after aString.
	Use default collation order (with case differences)."

	^ (self comparewith: aString collated: nil) = 3
]

{ #category : #all }
OptimizedString >> >= aString [
	"Answer whether the receiver sorts after or equal to aString.
	Use default collation order (with case differences)."

	^ (self compareWith: aString collated: nil) >= 2
]

{ #category : #all }
OptimizedString >> asByteArray [
	"Answer a ByteArray containing the ASCII values of my characters. Uses a fast primitive that avoids character conversion."

	<primitive: 'primitiveOptimizedStringAsByteArray' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> asUppercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	<primitive: 'primitiveOptimizedStringAsUppercase' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> asLowercase [
	"Answer a String made up from the receiver whose characters are all lowercase."

	<primitive: 'primitiveOptimizedStringAsLowercase' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> asString [
	"Answer this string."

	^ self
]

{ #category : #all }
OptimizedString >> asSymbol [
	"This is the only place that new Symbols are created. A Symbol is created if and only if there is not already a Symbol with its contents in existance."

	^ Symbol fromString: self
]

{ #category : #all }
OptimizedString >> at: index [
	"Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds."

	<primitive: 'primitiveOptimizedStringAt:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> at: index put: aCharacter [
	"Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character."

	<primitive: 'primitiveOptimizedStringAt:put:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> do: aBlock [
	1 to: self size do: [ :i | aBlock value: (self at: i) ]
]

{ #category : #all }
OptimizedString >> compare: aString [
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	The collation sequence is default with case differences ignored.
	To get the effect of a <= b, but ignoring case, use (a compare: b) <= 2."

	^ self compareWith: aString collated: #'no-case'
]

{ #category : #all }
OptimizedString >> compareWith: aString collated: order [
	"Return 1, 2 or 3, if receiver is <, =, or > aString, with the collating order of characters given by the order array."

	<primitive: 'primitiveOptimizedStringCompareWith:collated:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> findString: key startingAt: start caseSensitive: caseSensitive [
	"Answer the index in this String at which the substring key first occurs at or after the given starting index. The match can be case-sensitive or not. Answer zero if no match is found."

	^ self
		findSubstring: key
		startingAt: start
		collated:
			(caseSensitive
				ifTrue: [ #case ]
				ifFalse: [ #'no-case' ])
]

{ #category : #all }
OptimizedString >> findSubstring: key startingAt: start collated: order [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start. The match is determined using collation, which can be used to effect, eg, case-insensitive matches. If no match is found, zero will be returned."

	<primitive: 'primitiveOptimizedStringFindSubstring:startingAt:collated:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> copyFrom: start to: stop [
	"Answer a copy of a subset of the receiver, starting from element at
	index start until element at index stop."

	<primitive: 'primitiveOptimizedStringCopyFrom:to:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> substrings [
	^ self findTokens: ' '
]

{ #category : #all }
OptimizedString >> findTokens: delimiters [
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
OptimizedString >> skipDelimiters: delimiters startingAt: start [
	"Answer the index of the first character in this string starting at the given index that does NOT match one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1. Assumes the delimiters to be a non-empty string."

	start to: self size do: [ :i | 
		(delimiters indexOf: (self at: i) startingAt: 1) = 0
			ifTrue: [ ^ i ] ].
	^ self size + 1
]

{ #category : #all }
OptimizedString >> findDelimiters: delimiters startingAt: start [
	"Answer the index of the character within the receiver, starting at start, that matches one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1."

	start to: self size do: [ :i | 
		delimiters
			do: [ :delim | 
				delim = (self at: i)
					ifTrue: [ ^ i ] ] ].
	^ self size + 1
]

{ #category : #all }
OptimizedString >> includesSubstring: substring [
	"Returns whether the receiver contains the argument."
	"('abcdefgh' includesSubstring: 'de') >>> true"

	^ substring isEmpty or: [ (self findString: substring startingAt: 1 caseSensitive: true) > 0 ]
]

{ #category : #all }
OptimizedString >> hash [
	^ self class stringHash: self initialHash: 0
]

{ #category : #all }
OptimizedString >> indexOf: aCharacter startingAt: start [
	<primitive: 'primitiveOptimizedStringIndexOf:startingAt:' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> indexOf: aCharacter startingAt: startIndex ifAbsent: absentBlock [
	"Answer the index of the given Character within me starting the search at the given index. If I do not contain the Character, answer the result of evaluating the given block."

	| index |
	index := self indexOf: aCharacter startingAt: startIndex.
	^ index = 0
		ifTrue: [ absentBlock value ]
		ifFalse: [ index ]
]

{ #category : #all }
OptimizedString >> numArgs [
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
OptimizedString >> printOn: aStream [
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
OptimizedString >> replaceFrom: start to: stop with: replacement [
	"This destructively replaces elements from start to stop in the receiver. 
	Answer the receiver itself. Use copyReplaceFrom:to:with: for 
	insertion/deletion which may alter the size of the result."

	replacement size = (stop - start + 1)
		ifFalse: [ self error: 'Size of replacement doesnt match' ].
	^ self
		replaceFrom: start
		to: stop
		with: replacement
		startingAt: 1
]

{ #category : #all }
OptimizedString >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 'primitiveOptimizedStringReplaceFrom:to:with:startingAt:' module: 'CpSystemPlugin'>
	self replaceFrom: start to: stop with: (OptimizedString fromByteString: replacement) startingAt: repStart
]

{ #category : #all }
OptimizedString >> size [
	"Primitive. Answer the number of indexable fields in the receiver. This
	value is the same as the largest legal subscript."

	<primitive: 'primitiveOptimizedStringSize' module: 'CpSystemPlugin'>
]

{ #category : #all }
OptimizedString >> truncateTo: smallSize [
	"return myself or a copy shortened to smallSize."

	^ self size <= smallSize
		ifTrue: [ self ]
		ifFalse: [ self copyFrom: 1 to: smallSize ]
]

{ #category : #all }
OptimizedString >> translate: aString from: start to: stop table: table [
	"Translate the characters in the given string in place using the given mapping table."

	self error: 'Not implemented yet: OptimizedString >> $translate:from:to:table:'
]

{ #category : #all }
OptimizedString >> isString [
	^ true
]

{ #category : #all }
OptimizedString >> cpEncodeWith: anEncoder [
	anEncoder encodeString: self
]
