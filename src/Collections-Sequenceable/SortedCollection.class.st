Class {
	#name : #SortedCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'sortBlock'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #all }
SortedCollection class >> sortBlock: aBlock [
	^ self new sortBlock: aBlock
]

{ #category : #all }
SortedCollection >> , otherCollection [
	| newSortedCollection |
	newSortedCollection := super , otherCollection.
	newSortedCollection sortBlock: self sortBlock.
	^ newSortedCollection
]

{ #category : #all }
SortedCollection >> = aSortedCollection [
	"Answer true if my and aSortedCollection's species are the same,
	and if our blocks are the same, and if our elements are the same."

	self species = aSortedCollection species ifFalse: [ ^ false ].
	^ sortBlock = aSortedCollection sortBlock and: [ super = aSortedCollection ]
]

{ #category : #all }
SortedCollection >> add: newObject [
	^ super insert: newObject before: (self indexForInserting: newObject)
]

{ #category : #all }
SortedCollection >> addAll: aCollection [
	aCollection size > (self size // 3)
		ifTrue: [
			aCollection do: [ :each | super addLast: each ].
			self reSort ]
		ifFalse: [ aCollection do: [ :each | self add: each ] ].
	^ aCollection
]

{ #category : #all }
SortedCollection >> collect: aBlock [
	"Evaluate aBlock with each of my elements as the argument. Collect the
	resulting values into an OrderedCollection. Answer the new collection.
	We cannot assume that the result is sorted, because aBlock can transform the
	elements in arbitrary ways.  Thus, we must override the superclass in order
	to produce an OrderedCollection instead of a SortedCollection."

	| newCollection |
	newCollection := OrderedCollection new: self size.
	self do: [ :each | newCollection addLast: (aBlock value: each) ].
	^ newCollection
]

{ #category : #all }
SortedCollection >> defaultSort: i to: j [
	"Sort elements i through j of self to be nondescending according to
	sortBlock."	"Assume the default sort block ([:x :y | x <= y])."

	| di dij dj tt ij k l n |
	"The prefix d means the data at that index."
	(n := j + 1  - i) <= 1 ifTrue: [^self].	"Nothing to sort."
	 "Sort di,dj."
	di := array at: i.
	dj := array at: j.
	(di <= dj) "i.e., should di precede dj?"
		ifFalse:
			[array swap: i with: j.
			 tt := di.
			 di := dj.
			 dj := tt].
	n > 2
		ifTrue:  "More than two elements."
			[ij := (i + j) // 2.  "ij is the midpoint of i and j."
			 dij := array at: ij.  "Sort di,dij,dj.  Make dij be their median."
			 (di <= dij) "i.e. should di precede dij?"
			   ifTrue:
				[(dij <= dj) "i.e., should dij precede dj?"
				  ifFalse:
					[array swap: j with: ij.
					 dij := dj]]
			   ifFalse:  "i.e. di should come after dij"
				[array swap: i with: ij.
				 dij := di].
			n > 3
			  ifTrue:  "More than three elements."
				["Find k>i and l<j such that dk,dij,dl are in reverse order.
				Swap k and l.  Repeat this procedure until k and l pass each other."
				 k := i.
				 l := j.
				 [[l := l - 1.  k <= l and: [dij <= (array at: l)]]
				   whileTrue.  "i.e. while dl succeeds dij"
				  [k := k + 1.  k < j and: [(array at: k) <= dij]]
				   whileTrue.  "i.e. while dij succeeds dk"
				  k <= l]
				   whileTrue:
					[array swap: k with: l].
	"Now l<k (either 1 or 2 less), and di through dl are all less than or equal to dk
	through dj.  Sort those two segments."
				self defaultSort: i to: l.
				self defaultSort: k to: j]]
]

{ #category : #all }
SortedCollection >> indexForInserting: newObject [

	| index low high |
	low := firstIndex.
	high := lastIndex.
	sortBlock
		ifNil: [[index := high + low // 2.  low > high]
			whileFalse:
				[((array at: index) <= newObject)
					ifTrue: [low := index + 1]
					ifFalse: [high := index - 1]]]
		ifNotNil: [[index := high + low // 2.  low > high]
			whileFalse:
				[(sortBlock value: (array at: index) value: newObject)
					ifTrue: [low := index + 1]
					ifFalse: [high := index - 1]]].
	^low
]

{ #category : #all }
SortedCollection >> reSort [
	self sort: firstIndex to: lastIndex
]

{ #category : #all }
SortedCollection >> sort: aSortBlock [
	"Sort this array using aSortBlock. The block should take two arguments
	and return true if the first element should preceed the second one."

 	super sort: aSortBlock.
 	sortBlock := aSortBlock
]

{ #category : #all }
SortedCollection >> sort: i to: j [
	"Sort elements i through j of self to be nondescending according to
	sortBlock."

	| di dij dj tt ij k l n |
	sortBlock ifNil: [^self defaultSort: i to: j].
	"The prefix d means the data at that index."
	(n := j + 1  - i) <= 1 ifTrue: [^self].	"Nothing to sort."
	 "Sort di,dj."
	di := array at: i.
	dj := array at: j.
	(sortBlock value: di value: dj) "i.e., should di precede dj?"
		ifFalse:
			[array swap: i with: j.
			 tt := di.
			 di := dj.
			 dj := tt].
	n > 2
		ifTrue:  "More than two elements."
			[ij := (i + j) // 2.  "ij is the midpoint of i and j."
			 dij := array at: ij.  "Sort di,dij,dj.  Make dij be their median."
			 (sortBlock value: di value: dij) "i.e. should di precede dij?"
			   ifTrue:
				[(sortBlock value: dij value: dj) "i.e., should dij precede dj?"
				  ifFalse:
					[array swap: j with: ij.
					 dij := dj]]
			   ifFalse:  "i.e. di should come after dij"
				[array swap: i with: ij.
				 dij := di].
			n > 3
			  ifTrue:  "More than three elements."
				["Find k>i and l<j such that dk,dij,dl are in reverse order.
				Swap k and l.  Repeat this procedure until k and l pass each other."
				 k := i.
				 l := j.
				 [[l := l - 1.  k <= l and: [sortBlock value: dij value: (array at: l)]]
				   whileTrue.  "i.e. while dl succeeds dij"
				  [k := k + 1.  k < j and: [sortBlock value: (array at: k) value: dij]]
				   whileTrue.  "i.e. while dij succeeds dk"
				  k <= l]
				   whileTrue:
					[array swap: k with: l].
	"Now l<k (either 1 or 2 less), and di through dl are all less than or equal to dk
	through dj.  Sort those two segments."
				self sort: i to: l.
				self sort: k to: j]]
]

{ #category : #all }
SortedCollection >> sortBlock [
	^ sortBlock
]

{ #category : #all }
SortedCollection >> sortBlock: aBlock [
	sortBlock := aBlock.
	self size > 0 ifTrue: [ self reSort ]
]

{ #category : #all }
SortedCollection >> addFirst: newObject [
	self shouldNotImplement
]

{ #category : #all }
SortedCollection >> addLast: newObject [
	self shouldNotImplement
]

{ #category : #all }
SortedCollection >> at: anInteger put: anObject [
	self shouldNotImplement
]

{ #category : #all }
SortedCollection >> insert: anObject before: spot [
	self shouldNotImplement
]
