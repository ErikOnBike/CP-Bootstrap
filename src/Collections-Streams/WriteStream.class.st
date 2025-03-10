Class {
	#name : #WriteStream,
	#superclass : #ReadStream,
	#instVars : [
		'writeLimit'
	],
	#category : #'Collections-Streams'
}

{ #category : #all }
WriteStream >> contents [
	"Answer with a copy of my collection up to the high-water mark that was written."

	readLimit := readLimit max: position.
	^ collection copyFrom: 1 to: readLimit
]

{ #category : #all }
WriteStream >> directContents [
	"If the receiver's collection is fully matching the contents (no additional elements present),
	answer the collection itself, otherwise answer a copy of only the contents.
	Be careful using the result and the receiver after a call to this method, since the receiver's
	internal structure does not allow external changes.
	Only use when collection is in the caller's control, like #streamContents:"

	^ position = writeLimit
		ifTrue: [ collection ]
		ifFalse: [
			readLimit := readLimit max: position.
			collection copyFrom: 1 to: readLimit ]
]

{ #category : #all }
WriteStream >> nextPut: anObject [
	"Insert the argument at the next position in the Stream represented by the receiver. Fail if the collection of this stream is not an Array or a String. Fail if the stream is positioned at its end, or if the position is out of bounds in the collection. Fail if the argument is not of the right type for the collection."

	position >= writeLimit
		ifTrue: [ ^ self pastEndPut: anObject ]
		ifFalse: [ position := position + 1.
			^ collection at: position put: anObject ]
]

{ #category : #all }
WriteStream >> nextPutAll: aCollection [
	"Write the elements of the given collection starting at my current position. Answer the collection."

	"Optimization: If the given collection has the same class as my collection, use the fast operation replaceFrom:to:with:."

	| newEnd |
	collection class == aCollection class
		ifFalse: [ aCollection do: [ :v | self nextPut: v ].
			^ aCollection ].
	newEnd := position + aCollection size.
	newEnd > writeLimit
		ifTrue: [ collection := collection
				,
					(collection species
						new: newEnd - writeLimit + (collection size max: 20)).
			writeLimit := collection size ].
	"grow my collection if necessary"
	collection replaceFrom: position + 1 to: newEnd with: aCollection.
	position := newEnd
]

{ #category : #all }
WriteStream >> print: anObject [
	"Have anObject print itself on the receiver."

	anObject printOn: self
]

{ #category : #all }
WriteStream >> on: aCollection [
	super on: aCollection.
	readLimit := 0.
	writeLimit := aCollection size
]

{ #category : #all }
WriteStream >> pastEndPut: anObject [
	"Grow my collection."

	"Details: In general, double my size. Grow by at least 20 elements if my size is under 20 and grow by 20000 if my size is over 20000."

	collection := collection
		, (collection class new: ((collection size max: 20) min: 20000)).
	writeLimit := collection size.
	collection at: (position := position + 1) put: anObject
]

{ #category : #all }
WriteStream >> position: anInteger [
	"Set my read position, but remember the high-water mark that was written."

	readLimit := readLimit max: position.
	super position: anInteger
]

{ #category : #all }
WriteStream >> size [
	^ readLimit := readLimit max: position
]

{ #category : #all }
WriteStream >> space [
	"Append a space character to me."

	self nextPut: $  "literal space"
]

{ #category : #all }
WriteStream >> ifPastPrintOnCutOff: aBlock [
	"Evaluate the specified Block if the size of the receiver's contents is too big for #printOn:"

	self size > 16000
		ifTrue: [ aBlock value ]
]

{ #category : #all }
WriteStream >> nextPutPrintOnCutOff [
	"Add message showing cut off has taken place on #printOn:.
	Remember this message can be show multiple times if an Object
	has many relations which are all printed, since a check for the
	cut off is typically only made on entering a #printOn: method
	and not after every individual addition."

	self nextPutAll: '... >>> #printOn: cut off because of size'
]
