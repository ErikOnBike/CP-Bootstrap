Class {
	#name : #SequenceableCollection,
	#superclass : #Collection,
	#category : #'Collections-Abstract'
}

{ #category : #all }
SequenceableCollection class >> streamContents: blockWithArg [

	^ self new: 100 streamContents: blockWithArg
]

{ #category : #all }
SequenceableCollection class >> new: newSize streamContents: blockWithArg [
	| stream |
	stream := WriteStream on: (self streamSpecies new: newSize).
	blockWithArg value: stream.
	^ stream contents
]

{ #category : #all }
SequenceableCollection class >> streamSpecies [
	"I return the class that is used for streaming. If override consider overriding #new:streamContents:"
	^ self
]

{ #category : #all }
SequenceableCollection >> , otherCollection [
	"Concatenate two Strings or Collections."

	^ self
		copyReplaceFrom: self size + 1
		to: self size
		with: otherCollection	"
#(2 4 6 8) , #(who do we appreciate)
((2989 printStringBase: 16) copyFrom: 4 to: 6) , ' boy!'
"
]

{ #category : #all }
SequenceableCollection >> = otherCollection [
	"Answer whether the species of the receiver is the same as
	otherCollection's species, and the receiver's size is the same as
	otherCollection's size, and each of the receiver's elements equal the
	corresponding element of otherCollection."

	| size |
	(size := self size) = otherCollection size
		ifFalse: [ ^ false ].
	self species == otherCollection species
		ifFalse: [ ^ false ].
	1 to: size do: [ :index | 
		(self at: index) = (otherCollection at: index)
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #all }
SequenceableCollection >> asArray [
	"Answer an Array whose elements are the elements of the receiver, in the same order."

	| newArray |
	newArray := Array new: self size.
	1 to: self size do: [ :index | newArray at: index put: (self at: index) ].
	^ newArray
]

{ #category : #all }
SequenceableCollection >> at: index ifAbsent: absentBlock [
	"Answer the element at the given index. If I do not contain an element at that index, answer the result of evaluating the argument, absentBlock."

	(index between: 1 and: self size)
		ifTrue: [ ^ self at: index ].
	^ absentBlock value
]

{ #category : #all }
SequenceableCollection >> collect: aBlock [
	"Refer to the comment in Collection|collect:."

	| result |
	result := self species new: self size.
	1 to: self size do: [ :index | result at: index put: (aBlock value: (self at: index)) ].
	^ result
]

{ #category : #all }
SequenceableCollection >> allButFirst [
	^ self allButFirst: 1
]

{ #category : #all }
SequenceableCollection >> allButFirst: n [
	^ self copyFrom: n + 1 to: self size
]

{ #category : #all }
SequenceableCollection >> allButLast [
	^ self allButLast: 1
]

{ #category : #all }
SequenceableCollection >> allButLast: n [
	^ self copyFrom: 1 to: self size - n
]

{ #category : #all }
SequenceableCollection >> copyFrom: start to: stop [
	"Answer a copy of a subset of the receiver, starting from element at 
	index start until element at index stop."

	| newSize |
	newSize := stop - start + 1.
	^ (self species new: newSize)
		replaceFrom: 1
		to: newSize
		with: self
		startingAt: start
]

{ #category : #all }
SequenceableCollection >> copyReplaceFrom: start to: stop with: replacementCollection [
	"Answer a copy of the receiver satisfying the following conditions: If 
	stop is less than start, then this is an insertion; stop should be exactly 
	start-1, start = 1 means insert before the first character, start = size+1 
	means append after last character. Otherwise, this is a replacement; start 
	and stop have to be within the receiver's bounds."

	| newSequenceableCollection newSize endReplacement |
	newSize := self size - (stop - start + 1)
		+ replacementCollection size.
	endReplacement := start - 1 + replacementCollection size.
	newSequenceableCollection := self species new: newSize.
	newSequenceableCollection
		replaceFrom: 1
		to: start - 1
		with: self
		startingAt: 1.
	newSequenceableCollection
		replaceFrom: start
		to: endReplacement
		with: replacementCollection
		startingAt: 1.
	newSequenceableCollection
		replaceFrom: endReplacement + 1
		to: newSize
		with: self
		startingAt: stop + 1.
	^ newSequenceableCollection
]

{ #category : #all }
SequenceableCollection >> copyWith: newElement [
	"Answer a copy of the receiver that is 1 bigger than the receiver and has 
	newElement at the last element."

	| newIC |
	newIC := self species new: self size + 1.
	newIC
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1.
	newIC at: newIC size put: newElement.
	^ newIC
]

{ #category : #all }
SequenceableCollection >> do: aBlock [
	"Refer to the comment in Collection|do:."

	1 to: self size do: [ :index | aBlock value: (self at: index) ]
]

{ #category : #all }
SequenceableCollection >> withIndexDo: aBlock [
	"Just like do: except that the iteration index supplies the second argument to the block"

	1 to: self size do: [ :index | aBlock value: (self at: index) value: index ]
]

{ #category : #all }
SequenceableCollection >> first [
	^ self at: 1
]

{ #category : #all }
SequenceableCollection >> second [
	^ self at: 2
]

{ #category : #all }
SequenceableCollection >> third [
	^ self at: 3
]

{ #category : #all }
SequenceableCollection >> fourth [
	^ self at: 4
]

{ #category : #all }
SequenceableCollection >> indexOf: anObject ifAbsent: absentBlock [
	"Answer the index of the given object within me. If I do not contain the given object, answer the result of evaluating the given block."

	^ self indexOf: anObject startingAt: 1 ifAbsent: absentBlock
]

{ #category : #all }
SequenceableCollection >> indexOf: anObject startingAt: startIndex ifAbsent: absentBlock [
	"Answer the index of the given object within me starting the search at the given index. If I do not contain the given object, answer the result of evaluating the given block."

	startIndex to: self size do: [ :i | 
		(self at: i) = anObject
			ifTrue: [ ^ i ] ].
	^ absentBlock value
]

{ #category : #all }
SequenceableCollection >> last [
	"Answer the last element of the receiver. Create an error notification if 
	the receiver contains no elements."

	self emptyCheck.
	^ self at: self size
]

{ #category : #all }
SequenceableCollection >> beginsWith: aSequenceableCollection [
	"Answer true if the receiver starts with the argument collection."
	
	| sequenceSize |
	self size < (sequenceSize := aSequenceableCollection size) ifTrue: [ ^false ].
	1 to: sequenceSize do: [ :index |
		(aSequenceableCollection at: index) = (self at: index) ifFalse: [ ^false ] ].
	^true
]

{ #category : #all }
SequenceableCollection >> endsWith: aSequenceableCollection [
	"Answer true if the receiver ends with the argument collection."
	
	| sequenceSize offset |
	sequenceSize := aSequenceableCollection size.
	(offset := self size - sequenceSize) < 0 ifTrue: [ ^false ].
	1 to: sequenceSize do: [ :index |
		(aSequenceableCollection at: index) = (self at: index + offset) ifFalse: [ ^false ] ].
	^true
]

{ #category : #all }
SequenceableCollection >> findFirst: aBlock [
	"Return the index of my first element for which aBlock evaluates as true."

	| index currentSize |
	
	index := 0.
	currentSize := self size.
	
	[ (index := index + 1) <= currentSize ] whileTrue:
		[ (aBlock value: (self at: index)) ifTrue: [ ^ index ] ].
	
	^ 0
]

{ #category : #all }
SequenceableCollection >> withIndexDo: elementAndIndexBlock [
	"Just like with:do: except that the iteration index supplies the second argument to the block. "

	1 to: self size do: [ :index | elementAndIndexBlock value: (self at: index) value: index ]
]

{ #category : #all }
SequenceableCollection >> remove: oldObject ifAbsent: anExceptionBlock [
	"SequencableCollections cannot implement removing."

	self shouldNotImplement
]

{ #category : #all }
SequenceableCollection >> replaceFrom: start to: stop with: replacement [
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
SequenceableCollection >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"This destructively replaces elements from start to stop in the receiver 
	starting at index, repStart, in the sequenceable collection, 
	replacementCollection. Answer the receiver. No range checks are 
	performed."

	| index repOff |
	repOff := repStart - start.
	index := start - 1.
	[ (index := index + 1) <= stop ]
		whileTrue: [ self at: index put: (replacement at: repOff + index) ]
]

{ #category : #all }
SequenceableCollection >> select: aBlock [
	"Refer to the comment in Collection|select:."

	| s |
	s := WriteStream on: (self species new: self size).
	1 to: self size do: [ :i | 
		(aBlock value: (self at: i))
			ifTrue: [ s nextPut: (self at: i) ] ].
	^ s contents
]

{ #category : #all }
SequenceableCollection >> size [
	self subclassResponsibility
]

{ #category : #all }
SequenceableCollection >> swap: oneIndex with: anotherIndex [
	"Move the element at oneIndex to anotherIndex, and vice-versa."

	| element |
	element := self at: oneIndex.
	self at: oneIndex put: (self at: anotherIndex).
	self at: anotherIndex put: element
]
