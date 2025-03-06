Class {
	#name : #OrderedDictionary,
	#superclass : #Collection,
	#instVars : [
		'dictionary',
		'orderedKeys'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #all }
OrderedDictionary class >> new [
	^ self new: 10
]

{ #category : #all }
OrderedDictionary class >> new: anInteger [
	^ self basicNew
		initialize: anInteger ;
		yourself
]

{ #category : #all }
OrderedDictionary >> initialize: anInteger [
	dictionary := Dictionary new: anInteger.
	orderedKeys := Array new: anInteger
]

{ #category : #all }
OrderedDictionary >> add: anAssociation [
	| oldSize |

	oldSize := dictionary size.
	dictionary add: anAssociation.
	dictionary size > oldSize
		ifTrue: [
			orderedKeys size > oldSize
				ifFalse: [ self growOrderedKeys ].
			orderedKeys at: oldSize + 1 put: anAssociation key ].
	^ anAssociation
]

{ #category : #all }
OrderedDictionary >> addAll: anAssociationCollection [
	anAssociationCollection associationsDo: [ :each | self add: each ].
	^ anAssociationCollection
]

{ #category : #all }
OrderedDictionary >> associationAt: key [
	^ dictionary associationAt: key
]

{ #category : #all }
OrderedDictionary >> associationAt: key ifAbsent: aBlock [
	^ dictionary associationAt: key ifAbsent: aBlock
]

{ #category : #all }
OrderedDictionary >> associationAt: key ifAbsentPut: aBlock [
	^ dictionary associationAt: key ifAbsent: [ self associationAt: key put: aBlock value ]
]

{ #category : #all }
OrderedDictionary >> associations [
	"Return an array whose elements are the associations of the receiver"

	| s |
	s := WriteStream on: (Array new: self size).
	self associationsDo: [ :el | s nextPut: el ].
	^ s contents
]

{ #category : #all }
OrderedDictionary >> associationsDo: aBlock [
	self keysDo: [ :each | aBlock value: (self associationAt: each) ]
]

{ #category : #all }
OrderedDictionary >> at: key [
	^ dictionary at: key
]

{ #category : #all }
OrderedDictionary >> at: key ifPresent: aBlock ifAbsent: exceptionBlock [
	^ dictionary at: key ifPresent: aBlock ifAbsent: exceptionBlock
]

{ #category : #all }
OrderedDictionary >> at: key ifAbsent: aBlock [
	^ dictionary at: key ifAbsent: aBlock
]

{ #category : #all }
OrderedDictionary >> at: key ifPresent: aBlock [
	^ dictionary at: key ifPresent: aBlock
]

{ #category : #all }
OrderedDictionary >> at: key ifPresent: aBlock ifAbsentPut: exceptionBlock [
	^ dictionary at: key ifPresent: aBlock ifAbsent: [ self at: key put: exceptionBlock value ]
]

{ #category : #all }
OrderedDictionary >> at: key ifAbsentPut: aBlock [
	^ dictionary at: key ifAbsent: [ self at: key put: aBlock value ]
]

{ #category : #all }
OrderedDictionary >> at: key put: anObject [
	| oldSize value |

	oldSize := dictionary size.
	value := dictionary at: key put: anObject.
	dictionary size > oldSize
		ifTrue: [
			orderedKeys size > oldSize
				ifFalse: [ self growOrderedKeys ].
			orderedKeys at: oldSize + 1 put: key ].
	^ value
]

{ #category : #all }
OrderedDictionary >> collect: aBlock [
	"Evaluate aBlock with each of my values as the argument. Collect the resulting values into a collection that is like me. Answer with the new collection."

	| newCollection |
	newCollection := self species new.
	self associationsDo: [ :each | newCollection add: each key -> (aBlock value: each value) ].
	^ newCollection
]

{ #category : #all }
OrderedDictionary >> postCopy [
	orderedKeys := orderedKeys copy.
	dictionary := dictionary copy
]

{ #category : #all }
OrderedDictionary >> do: aBlock [
	self valuesDo: aBlock
]

{ #category : #all }
OrderedDictionary >> errorInvalidIndex: anInteger [
	self error: 'index out of bounds ', anInteger printString
]

{ #category : #all }
OrderedDictionary >> errorKeyNotFound [
	self error: 'key not found'
]

{ #category : #all }
OrderedDictionary >> errorValueNotFound [
	self error: 'value not found'
]

{ #category : #all }
OrderedDictionary >> includes: anObject [
	^ dictionary includes: anObject
]

{ #category : #all }
OrderedDictionary >> includesKey: key [
	^ dictionary includesKey: key
]

{ #category : #all }
OrderedDictionary >> keyAtIndex: index [
	^ self keyAtIndex: index ifAbsent: [ self errorInvalidIndex: index ]
]

{ #category : #all }
OrderedDictionary >> keyAtIndex: index ifAbsent: exceptionBlock [
	^ (index > 0 and: [ index <= self size ])
		ifTrue: [ orderedKeys at: index ]
		ifFalse: [ exceptionBlock value ]
]

{ #category : #all }
OrderedDictionary >> keyAtValue: value [
	^ dictionary keyAtValue: value
]

{ #category : #all }
OrderedDictionary >> keyAtValue: value ifAbsent: exceptionBlock [
	^ dictionary keyAtValue: value ifAbsent: exceptionBlock
]

{ #category : #all }
OrderedDictionary >> keyAtIdentityValue: value [
	^ dictionary keyAtIdentityValue: value
]

{ #category : #all }
OrderedDictionary >> keyAtIdentityValue: value ifAbsent: exceptionBlock [
	^ dictionary keyAtIdentityValue: value ifAbsent: exceptionBlock
]

{ #category : #all }
OrderedDictionary >> keys [
	^ orderedKeys copyFrom: 1 to: self size
]

{ #category : #all }
OrderedDictionary >> keysDo: aBlock [
	1 to: self size do: [ :i | aBlock value: (orderedKeys at: i) ]
]

{ #category : #all }
OrderedDictionary >> values [
	"Answer an Array containing the receiver's values."

	^ Array new: self size streamContents: [ :stream | self valuesDo: [ :each | stream nextPut: each ] ]
]

{ #category : #all }
OrderedDictionary >> valuesDo: aBlock [
	self keysDo: [ :each | aBlock value: (self at: each) ]
]

{ #category : #all }
OrderedDictionary >> keysAndValuesDo: aBlock [
	self keysDo: [ :each | aBlock value: each value: (self at: each) ]
]

{ #category : #all }
OrderedDictionary >> printOn: aStream [
	aStream nextPutAll: self class name , ' ('.
	self
		associationsDo: [ :element | 
			element printOn: aStream.
			aStream space ].
	aStream nextPut: $)
]

{ #category : #all }
OrderedDictionary >> remove: anObject [
	self shouldNotImplement
]

{ #category : #all }
OrderedDictionary >> remove: anObject ifAbsent: exceptionBlock [
	self shouldNotImplement
]

{ #category : #all }
OrderedDictionary >> removeKey: key [
	"Remove key from the receiver.
	If key is not in the receiver, notify an error."

	^ self removeKey: key ifAbsent: [ self errorKeyNotFound ]
]

{ #category : #all }
OrderedDictionary >> removeKey: key ifAbsent: aBlock [
	| oldSize value |

	oldSize := dictionary size.
	value := dictionary removeKey: key ifAbsent: aBlock.
	dictionary size < oldSize
		ifTrue: [ self orderedKeysRemove: key ].
	^ value
]

{ #category : #all }
OrderedDictionary >> removeAllSuchThat: aBlock [
	self associations do: [ :each | (aBlock value: each value) ifTrue: [ self removeKey: each key ] ]
]

{ #category : #all }
OrderedDictionary >> size [
	^ dictionary size
]

{ #category : #all }
OrderedDictionary >> select: aBlock [
	"Evaluate aBlock with each of my values as the argument. Collect into a
	new dictionary, only those associations for which aBlock evaluates to true."

	| newCollection |
	newCollection := self species new.
	self associationsDo: [ :each |
		(aBlock value: each value)
			ifTrue: [ newCollection add: each ] ].
	^ newCollection
]

{ #category : #all }
OrderedDictionary >> growOrderedKeys [

	orderedKeys := (Array new: ((orderedKeys size * 1.5) asInteger max: 10))
		replaceFrom: 1
		to: orderedKeys size
		with: orderedKeys
		startingAt: 1
]

{ #category : #all }
OrderedDictionary >> orderedKeysRemove: aRemovedKey [
	| index |

	index := orderedKeys indexOf: aRemovedKey ifAbsent: [ ^ self errorKeyNotFound ].

	"shift every remaining key after to the left by one"
	orderedKeys
		replaceFrom: index
		to: self size
		with: orderedKeys
		startingAt: index + 1.

	"make last element empty"
	orderedKeys
		at: self size + 1
		put: nil
]
