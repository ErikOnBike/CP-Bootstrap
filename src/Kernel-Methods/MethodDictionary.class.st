Class {
	#name : #MethodDictionary,
	#superclass : #Dictionary,
	#type : #variable,
	#category : #'Kernel-Methods'
}

{ #category : #all }
MethodDictionary class >> new: nElements [
	"Create a Dictionary large enough to hold nElements without growing."

	"NOTE: The basic size MUST be a power of 2. It is VITAL (see grow) that size gets doubled if nElements is a power of 2."

	| size |
	size := 1 bitShift: nElements highBit.
	^ (self basicNew: size) init: size
]

{ #category : #all }
MethodDictionary >> add: anAssociation [
	^ self at: anAssociation key put: anAssociation value
]

{ #category : #all }
MethodDictionary >> associationsDo: aBlock [
	| key |
	tally = 0
		ifTrue: [ ^ self ].
	1 to: self basicSize do: [ :i | 
		(key := self basicAt: i)
			ifNotNil: [ aBlock value: key -> (array at: i) ] ]
]

{ #category : #all }
MethodDictionary >> at: key ifAbsent: aBlock [
	| index |
	index := self findElementOrNil: key.
	(self basicAt: index) == nil
		ifTrue: [ ^ aBlock value ].
	^ array at: index
]

{ #category : #all }
MethodDictionary >> at: key put: value [
	"Set the value at key to be value."
	| index |
	index := self findElementOrNil: key.
	(self basicAt: index) == nil
		ifTrue: [ tally := tally + 1.
			self basicAt: index put: key ].
	array at: index put: value.
	self fullCheck.
	^ value
]

{ #category : #all }
MethodDictionary >> do: aBlock [
	tally = 0
		ifTrue: [ ^ self ].
	1 to: self basicSize do: [ :i | (self basicAt: i) ifNotNil: [ aBlock value: (array at: i) ] ]
]

{ #category : #all }
MethodDictionary >> grow [
	| newSelf key |
	newSelf := self species new: self basicSize.	"This will double the size"
	1 to: self basicSize do: [ :i | 
		key := self basicAt: i.
		key == nil
			ifFalse: [ newSelf at: key put: (array at: i) ] ].
	self become: newSelf
]

{ #category : #all }
MethodDictionary >> includesKey: aSymbol [
	"This override assumes that pointsTo is a fast primitive."

	^ super pointsTo: aSymbol
]

{ #category : #all }
MethodDictionary >> keyAt: index [
	^ self basicAt: index
]

{ #category : #all }
MethodDictionary >> keyAtIdentityValue: value ifAbsent: exceptionBlock [
	"Answer the key whose value equals the argument, value. If there is none, answer the result of evaluating exceptionBlock."

	| k |
	1 to: self basicSize do: [ :i | 
		value == (array at: i)
			ifTrue: [ (k := self basicAt: i) ifNotNil: [ ^ k ] ] ].
	^ exceptionBlock value
]

{ #category : #all }
MethodDictionary >> keysDo: aBlock [
	| key |
	tally = 0
		ifTrue: [ ^ self ].
	1 to: self basicSize do: [ :i | (key := self basicAt: i) ifNotNil: [ aBlock value: key ] ]
]

{ #category : #all }
MethodDictionary >> removeKey: key ifAbsent: errorBlock [
	"The interpreter might be using this MethodDictionary while
	this method is running! Therefore we perform the removal
	in a copy, and then atomically copy that copy"

	| copy |
	copy := self copy.
	copy removeDangerouslyKey: key ifAbsent: [ ^ errorBlock value ].
	self copyFrom: copy
]

{ #category : #all }
MethodDictionary >> removeDangerouslyKey: key ifAbsent: errorBlock [
	"This is not really dangerous.  But if normal removal
	were done WHILE a MethodDict were being used, the
	system might crash.  So instead we make a copy, then do
	this operation (which is NOT dangerous in a copy that is
	not being used), and then use the copy after the removal."

	| index element |
	index := self findElementOrNil: key.
	(self basicAt: index) ifNil: [ ^ aBlock value ].
	array at: index put: nil.
	self basicAt: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
]

{ #category : #all }
MethodDictionary >> copyFrom: anObject [
	"This is an explicit implementation for MethodDictionary."
	<primitive: 168>
]

{ #category : #all }
MethodDictionary >> postCopy [
	array := array copy
]

{ #category : #all }
MethodDictionary >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or zero if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| element start finish |
	start := anObject basicIdentityHash \\ array size + 1.
	finish := array size.	"Search from (hash mod size) to the end."
	start to: finish do: [ :index | 
		((element := self basicAt: index) == nil or: [ element == anObject ])
			ifTrue: [ ^ index ] ].	"Search from 1 to where we started."
	1 to: start - 1 do: [ :index | 
		((element := self basicAt: index) == nil or: [ element == anObject ])
			ifTrue: [ ^ index ] ].
	^ 0	"No match AND no empty slot"
]

{ #category : #all }
MethodDictionary >> swap: oneIndex with: otherIndex [
	| element |
	element := self basicAt: oneIndex.
	self basicAt: oneIndex put: (self basicAt: otherIndex).
	self basicAt: otherIndex put: element.
	super swap: oneIndex with: otherIndex
]
