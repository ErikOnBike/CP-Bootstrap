Class {
	#name : #Symbol,
	#superclass : #ByteString,
	#type : #bytes,
	#category : #'Kernel-Text'
}

{ #category : #all }
Symbol class >> streamSpecies [
	^ ByteString
]

{ #category : #all }
Symbol class >> initSymbolTable [
	"Initialize the internal symbol table. Should be called once, before new symbols are created through String >> #asSymbol"

	self allInstancesDo: [ :eachSymbol | self primRegister: eachSymbol ].
]

{ #category : #all }
Symbol class >> new: size [
	"Symbols are unique. You can create a new Symbol from a String using 'asSymbol'."

	self cannotInstantiate
]

{ #category : #all }
Symbol class >> fromString: aString [

	<primitive: 'primitiveSymbolFromString:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
Symbol class >> primRegister: aSymbol [

	<primitive: 'primitiveSymbolRegister:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
Symbol >> , otherSymbolOrString [
	"Concatenate the receiver with otherSymbolOrString and return the result.
	Overwritten to always return Symbol results,
	whether the argument is a Symbol or a String"

	^ (super , otherSymbolOrString) asSymbol
]

{ #category : #all }
Symbol >> = anObject [

	<primitive: 'primitiveSymbolEquals:' module: 'CpSystemPlugin'>
	^ self == anObject
]

{ #category : #all }
Symbol >> doesNotUnderstand: aMessage [

	"Special case when a class reference Symbol is receiver it means the actual Class
	did not get properly installed"

	self == #__ClassReference
		ifTrue: [
			| missingClasses |

			"Collect which Classes are missing (we don't know which is referenced without doing too much foo)"
			missingClasses := IdentitySet new.
			thisContext sender method withAllNestedLiteralsDo: [ :each |
				(each class = Association and: [ each value = #__ClassReference ])
					ifTrue: [ missingClasses add: each key ] ].

			"Show error message describing missing class(es) and which message was sent"
			self error: (String streamContents: [ :stream |
				stream
					nextPutAll: (missingClasses
						ifNotEmpty: [
							missingClasses size = 1
								ifTrue: [ 'Class' ]
								ifFalse: [ 'Classes' ] ]
						ifEmpty: [ 'Some Class' ]) ;
					space ;
					nextPutAll: (',' join: missingClasses) ;
					nextPutAll: ' not installed when sending: ' ;
					print: aMessage ]) ]
		ifFalse: [ super doesNotUnderstand: aMessage ]
]

{ #category : #all }
Symbol >> isSymbol [
	^ true
]

{ #category : #all }
Symbol >> isLiteralSymbol [

	<primitive: 'primitiveSymbolIsLiteralSymbol' module: 'CpSystemPlugin'>
	^ false
]

{ #category : #all }
Symbol >> capitalized [
	^ self asString capitalized asSymbol
]

{ #category : #all }
Symbol >> asString [
	"Answer a string containing my characters."

	| sz result |
	sz := self size.
	result := String new: sz.
	result
		replaceFrom: 1
		to: sz
		with: self
		startingAt: 1.
	^ result
]

{ #category : #all }
Symbol >> asSymbol [
	^ self
]

{ #category : #all }
Symbol >> at: anInteger put: anObject [
	"You cannot modify the receiver."

	self errorNoModification
]

{ #category : #all }
Symbol >> basicCopy [
	"Answer myself because Symbols are unique."

	
]

{ #category : #all }
Symbol >> errorNoModification [
	self error: 'Symbols can not be modified.'
]

{ #category : #all }
Symbol >> numArgs [
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
Symbol >> printOn: aStream [
	aStream nextPut: $#.
	self isLiteralSymbol
		ifTrue: [ aStream nextPutAll: self ]
		ifFalse: [ super printOn: aStream ]
]

{ #category : #all }
Symbol >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	self errorNoModification
]

{ #category : #all }
Symbol >> species [
	^ ByteString
]

{ #category : #all }
Symbol >> flushCache [
	<primitive: 119>
]

{ #category : #all }
Symbol >> cpEncodeWith: anEncoder [
	anEncoder encodeSymbol: self
]
