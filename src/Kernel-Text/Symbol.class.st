Class {
	#name : #Symbol,
	#superclass : #String,
	#type : #bytes,
	#category : #'Kernel-Text'
}

{ #category : #all }
Symbol class >> streamSpecies [
	^ String
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
Symbol >> = anObject [
	^ self == anObject
]

{ #category : #all }
Symbol >> isSymbol [
	^ true
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
Symbol >> hash [
	^ self identityHash
]

{ #category : #all }
Symbol >> initFrom: aString [
	"Warning! Use only to initialize new Symbols. Symbols are assumed to be immutable there after."

	self size = aString size
		ifFalse: [ self error: 'size mismatch' ].
	super
		replaceFrom: 1
		to: self size
		with: aString
		startingAt: 1
]

{ #category : #all }
Symbol >> printOn: aStream [
	aStream nextPutAll: self
]

{ #category : #all }
Symbol >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	self errorNoModification
]

{ #category : #all }
Symbol >> species [
	^ String
]

{ #category : #all }
Symbol >> flushCache [
	<primitive: 119>
]

{ #category : #all }
Symbol >> cpEncodeWith: anEncoder [
	anEncoder encodeSymbol: self
]
