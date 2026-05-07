Class {
	#name : #ConstantBlockClosure,
	#superclass : #CleanBlockClosure,
	#type : #variable,
	#category : #'Kernel-Methods'
}

{ #category : #all }
ConstantBlockClosure class >> numArgs: anInteger literal: anObject [
	^ self new
		numArgs: anInteger ;
		literal: anObject ;
		yourself
]

{ #category : #all }
ConstantBlockClosure >> bindClassVariablesTo: aClass [
	(literal class == (Smalltalk at: #ClassVariable) and: [ literal value == #__ClassVariable ])
		ifTrue: [ literal := aClass classVariableNamed: literal key ]
]

{ #category : #all }
ConstantBlockClosure >> errorArgCount: anInteger [

	self error: 'ConstantBlockClosure evaluated with ', anInteger printString, ' arguments, but ', numArgs printString, ' expected.'
]

{ #category : #all }
ConstantBlockClosure >> literal: anObject [
	literal := anObject
]

{ #category : #all }
ConstantBlockClosure >> value [

	numArgs = 0 ifFalse: [ self errorArgCount: 0 ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: anObject [

	numArgs = 1 ifFalse: [ self errorArgCount: 1 ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: firstObject value: secondObject [

	numArgs = 2 ifFalse: [ self errorArgCount: 2 ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: firstObject value: secondObject value: thirdObject [

	numArgs = 3 ifFalse: [ self errorArgCount: 3 ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: firstObject value: secondObject value: thirdObject value: fourthObject [

	numArgs = 4 ifFalse: [ self errorArgCount: 4 ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> valueWithArguments: anArray [

	numArgs = anArray size ifFalse: [ self errorArgCount: anArray size ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> withAllBlocksDo: aBlock [
	(literal isKindOf: BlockClosure)
		ifTrue: [ aBlock value: literal ]
]
