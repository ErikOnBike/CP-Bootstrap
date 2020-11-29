Class {
	#name : #CompiledMethod,
	#superclass : #ByteArray,
	#type : #bytes,
	#category : #'Kernel-Methods'
}

{ #category : #all }
CompiledMethod class >> newMethod: numberOfBytes header: headerWord [
	"Primitive. Answer an instance of me. The number of literals (and other 
	 information) is specified by the headerWord.
	 The first argument specifies the number of fields for bytecodes in the
	 method. Fail if either argument is not a SmallInteger, or if numberOfBytes
	 is negative, or if memory is low. Once the header of a method is set by
	 this primitive, it cannot be changed to change the number of literals.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79>
	^nil
]

{ #category : #all }
CompiledMethod >> frameSize [
	"Answer the size of temporary frame needed to run the receiver."

	"NOTE:  Versions 2.7 and later use two sizes of contexts."

	(self header bitAnd: 16r20000) = 0
		ifTrue: [ ^ 16 ]
		ifFalse: [ ^ 56 ]
]

{ #category : #all }
CompiledMethod >> header [
	"Answer the method header word containing information about the form of this method (e.g., number of literals) and the context needed to run it."

	^ self objectAt: 1
]

{ #category : #all }
CompiledMethod >> initialPC [
	"Answer the program counter for my first bytecode."

	^ (self numLiterals + 1) * Smalltalk wordSize + 1
]

{ #category : #all }
CompiledMethod >> endPC [
	"Answer the index of the last bytecode."
	| size flagByte |
	"Can't create a zero-sized CompiledMethod so no need to use last for the errorEmptyCollection check.
	 We can reuse size."
	size := self size.
	flagByte := self at: size.
	flagByte = 0 ifTrue: [
		"If last byte = 0, may be either 0, 0, 0, 0 or just 0"
		size-1 to: size-3 by: -1 do: [ :i |
			i < self initialPC ifTrue: [ ^ i ].
			(self at: i) = 0 ifFalse: [ ^ i ]].
		^size - 4].
	flagByte < 252 ifTrue: [
		"Magic sources (temp names encoded in last few bytes)"
		^flagByte <= 127
			ifTrue: [size - flagByte - 1]
			ifFalse: [size - (flagByte - 128 * 128) - (self at: size - 1) - 2]].
	"Normal 4-byte source pointer"
	^size - 4
]

{ #category : #all }
CompiledMethod >> penultimateLiteral [
	| pIndex |
	^ (pIndex := self numLiterals - 1) > 0 
		ifTrue: [ self literalAt: pIndex ]
		ifFalse: [ nil ]
]

{ #category : #all }
CompiledMethod >> selector [
	| penultimateLiteral | 
	^ (penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [ penultimateLiteral selector ]
		ifFalse: [ penultimateLiteral ]
]

{ #category : #all }
CompiledMethod >> properties [

	"Answer the method properties of the receiver.
	Implementation: currently only supported through method properties in receiver directly."

	| penultimateLiteral |
	^(penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [penultimateLiteral]
		ifFalse: [nil "self class methodPropertiesClass forMethod: self selector: penultimateLiteral"]
]

{ #category : #all }
CompiledMethod >> pragmas [
	^ self properties ifNotNil: [ :properties | properties pragmas ] ifNil: [ #() ]
]

{ #category : #all }
CompiledMethod >> isCompiledMethod [
	^ true
]

{ #category : #all }
CompiledMethod >> numLiterals [
	"Answer the number of literals used by the receiver."

	^ self header bitAnd: 16r7FFF
]

{ #category : #all }
CompiledMethod >> numTemps [
	"Answer the number of temporary variables used by this method."

	^ (self header bitShift: -18) bitAnd: 16r3F
]

{ #category : #all }
CompiledMethod >> literalAt: index [
	"Answer the literal indexed by the argument."

	^self objectAt: index + 1
]

{ #category : #all }
CompiledMethod >> literalAt: index put: value [
	"Replace the literal indexed by the first argument with the second 
	argument. Answer the second argument."

	^self objectAt: index + 1 put: value
]

{ #category : #all }
CompiledMethod >> objectAt: index [
	"Primitive. Answer the method header (if index = 1) or a literal (if index > 1) from the receiver. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 68>
	self primitiveFailed
]

{ #category : #all }
CompiledMethod >> objectAt: index put: value [
	"Primitive. Store the value argument into a literal in the receiver. An index of 2 corresponds to the first literal. Fails if the index is less than 2 or greater than the number of literals. Answer the value as the result. Normally only the compiler sends this message because only the compiler stores values in CompiledMethods. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 69>
	self primitiveFailed
]

{ #category : #all }
CompiledMethod >> methodClass [
	^self classBinding value
]

{ #category : #all }
CompiledMethod >> classBinding [
	"answer the association to the class that I am installed in, or nil if none."
	^self literalAt: self numLiterals
]

{ #category : #all }
CompiledMethod >> install [

	self methodClass
		ifNotNil: [ :methodClass | 
			methodClass addSelector: self selector withMethod: self.
			self bindClassVariablesTo: methodClass instanceSide ]
]

{ #category : #all }
CompiledMethod >> bindClassVariables [

	"Bind class variables to the receiver (replace literal association with class variable association).
	Assume the receiver is already bound to a class."

	self bindClassVariablesTo: self methodClass instanceSide
]

{ #category : #all }
CompiledMethod >> bindClassVariablesTo: aClass [

	"Bind class variables to the receiver (replace literal association with class variable association)"

	| classVariableClass |

	classVariableClass := Smalltalk at: #ClassVariable.
	1 to: self numLiterals do: [ :index |
		| literal |
		literal := self literalAt: index.
		(literal class == classVariableClass and: [ literal value isNil ])
			ifTrue: [ self literalAt: index put: (aClass classVariableNamed: literal key) ] ]
]

{ #category : #all }
CompiledMethod >> printOn: aStream [
	aStream
		nextPutAll: self methodClass name ;
		nextPutAll: '>>#' ;
		nextPutAll: self selector
]

{ #category : #all }
CompiledMethod >> primitive [
	"Answer the primitive index associated with the receiver.
	 Zero indicates that this is not a primitive method."
	| initialPC |
	^(self header anyMask: 65536) "Is the hasPrimitive? flag set?"
		ifTrue: [(self at: (initialPC := self initialPC) + 1) + ((self at: initialPC + 2) bitShift: 8)]
		ifFalse: [0]
]

{ #category : #all }
CompiledMethod >> cpEncodeWith: anEncoder [
	anEncoder encodeCompiledMethod: self
]
