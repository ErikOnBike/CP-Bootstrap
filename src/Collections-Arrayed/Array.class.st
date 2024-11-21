Class {
	#name : #Array,
	#superclass : #ArrayedCollection,
	#type : #variable,
	#category : #'Collections-Arrayed'
}

{ #category : #all }
Array >> asArray [
	"Answer with the receiver itself."

	^ self
]

{ #category : #all }
Array >> asDictionary [
	^ self asDictionary: Dictionary
]

{ #category : #all }
Array >> asOrderedDictionary [
	^ self asDictionary: OrderedDictionary
]

{ #category : #all }
Array >> asDictionary: dictionaryClass [
	| dictionary |

	dictionary := dictionaryClass new.
	self do: [ :each | dictionary add: each ].
	^ dictionary
]

{ #category : #all }
Array >> elementsExchangeIdentityWith: otherArray [
	"This primitive performs a bulk mutation, causing all pointers to the elements of this array to be replaced by pointers to the corresponding elements of otherArray.  At the same time, all pointers to the elements of otherArray are replaced by pointers to the corresponding elements of this array."

	<primitive: 128>
	self primitiveFailed
]

{ #category : #all }
Array >> elementsForwardIdentityTo: otherArray [
	"This primitive performs a bulk mutation, causing all pointers to the elements of this array to be replaced by pointers to the corresponding elements of otherArray.  At the same time, all pointers to the elements of otherArray are replaced by pointers to the corresponding elements of this array."

	<primitive: 72>
	self primitiveFailed
]

{ #category : #all }
Array >> hash [
	"Make sure that equal (=) arrays hash equally."

	self size = 0
		ifTrue: [ ^ 17171 ].
	^ (self at: 1) hash + (self at: self size) hash
]

{ #category : #all }
Array >> isArray [
	^ true
]

{ #category : #all }
Array >> printOn: aStream [
	aStream nextPutAll: '#('.
	1 to: (1000 min: self size) do: [ :index | 
		(self at: index) printOn: aStream.
		aStream space ].
	self size > 1000
		ifTrue: [ aStream nextPutAll: ' ...' ].
	aStream nextPut: $)
]

{ #category : #all }
Array >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super
		replaceFrom: start
		to: stop
		with: replacement
		startingAt: repStart
]

{ #category : #all }
Array >> cpEncodeWith: anEncoder [
	anEncoder encodeArray: self
]
