Class {
	#name : #Pragma,
	#superclass : #Object,
	#instVars : [
		'method',
		'selector',
		'arguments'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
Pragma class >> selector: aSymbol arguments: anArray [ 
	^ self new
		selector: aSymbol;
		arguments: anArray;
		yourself
]

{ #category : #all }
Pragma class >> withPragmasIn: aClass do: aBlock [
	aClass selectorsAndMethodsDo: [ :selector :method | method pragmas do: aBlock ]
]

{ #category : #all }
Pragma >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #all }
Pragma >> arguments: anArray [
	arguments := anArray
]

{ #category : #all }
Pragma >> argumentAt: index [
	^ self arguments at: index
]

{ #category : #all }
Pragma >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #all }
Pragma >> arguments [
	^ arguments
]

{ #category : #all }
Pragma >> numArgs [
	^ arguments size
]

{ #category : #all }
Pragma >> method [
	^ method
]

{ #category : #all }
Pragma >> selector [
	^ selector
]

{ #category : #all }
Pragma >> methodSelector [
	^ method selector
]

{ #category : #all }
Pragma >> key [
	^ self selector
]

{ #category : #all }
Pragma >> message [
	^ Message selector: self selector arguments: self arguments
]

{ #category : #all }
Pragma >> printOn: aStream [
	"Refer to the comment in Object|printOn:."

	super printOn: aStream.
	aStream
		nextPutAll: ' selector: ' , selector printString ;
		nextPutAll: ' args: ' , arguments printString
]

{ #category : #all }
Pragma >> = anObject [
	^ self class == anObject class
	  and: [ selector == anObject selector
	  and: [ arguments = anObject arguments ] ]
]

{ #category : #all }
Pragma >> hash [
	^ selector hash + arguments hash
]

{ #category : #all }
Pragma >> cpEncodeWith: anEncoder [
	anEncoder encodePragma: self
]
