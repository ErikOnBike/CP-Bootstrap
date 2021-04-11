Class {
	#name : #WideString,
	#superclass : #String,
	#type : #words,
	#category : #'Kernel-Text'
}

{ #category : #all }
WideString class >> from: aString [

	<primitive: 'primitiveWideStringFrom:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
WideString >> asSymbol [
	self error: 'WideSymbols are currently not supported'
]
