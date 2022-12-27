Class {
	#name : #SmalltalkImage,
	#superclass : #Object,
	#classVars : [],
	#instVars : [
		'globals'
	],
	#category : #'Kernel-System'
}

{ #category : #all }
SmalltalkImage >> at: aName [
	^ self at: aName ifAbsent: [ nil ]
]

{ #category : #all }
SmalltalkImage >> at: aName ifAbsent: aBlock [
	^ globals at: aName ifAbsent: aBlock
]

{ #category : #all }
SmalltalkImage >> at: aName put: aGlobalObject [
	globals at: aName put: aGlobalObject
]

{ #category : #all }
SmalltalkImage >> globalAssociationAt: aSymbol [
	^ globals associationAt: aSymbol ifAbsent: [ self error: 'Unknown global ', aSymbol printString ]
]

{ #category : #all }
SmalltalkImage >> globalAssociationAt: aSymbol ifAbsentPut: absentBlock [
	^ globals associationAt: aSymbol ifAbsentPut: absentBlock
]

{ #category : #all }
SmalltalkImage >> classNamed: aName [
	| global |

	global := self at: aName.
	^ global ifNotNil: [
		global isBehavior
			ifTrue: [ global ]
			ifFalse: [ nil ] ]
]

{ #category : #all }
SmalltalkImage >> globals [
	^ globals
]

{ #category : #all }
SmalltalkImage >> wordSize [
	^ 4
]

{ #category : #all }
SmalltalkImage >> registerExternalObject: anObject [
	^ System registerExternalObject: anObject
]

{ #category : #all }
SmalltalkImage >> unregisterExternalObject: anObject [
	System unregisterExternalObject: anObject
]

{ #category : #all }
SmalltalkImage >> specialObjectsArray [
	System specialObjectsArray
]
