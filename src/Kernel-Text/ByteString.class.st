Class {
	#name : #ByteString,
	#superclass : #String,
	#type : #bytes,
	#category : #'Kernel-Text'
}

{ #category : #all }
ByteString >> asByteArray [
	"Answer a ByteArray containing the ASCII values of my characters. Uses a fast primitive that avoids character conversion."

	^ (ByteArray new: self size)
		replaceFrom: 1
		to: self size
		with: self
]

{ #category : #all }
ByteString >> asSymbol [
	"This is the only place that new Symbols are created. A Symbol is created if and only if there is not already a Symbol with its contents in existance."

	^ Symbol fromString: self
]

{ #category : #all }
ByteString >> at: index put: aCharacter [

	aCharacter asInteger < 256
		ifTrue: [ ^ super at: index put: aCharacter ]
		ifFalse: [
			self becomeForward: (WideString from: self).
			^ self at: index put: aCharacter ]
]
