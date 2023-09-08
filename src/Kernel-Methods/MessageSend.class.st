Class {
	#name : #MessageSend,
	#superclass : #Object,
	#instVars : [
		'receiver',
		'selector',
		'arguments'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
MessageSend class >> message: aMessage to: anObject [
	^ self receiver: anObject selector: aMessage selector arguments: aMessage arguments
]

{ #category : #all }
MessageSend class >> receiver: anObject selector: aSymbol [
	^ self receiver: anObject selector: aSymbol arguments: #()
]

{ #category : #all }
MessageSend class >> receiver: anObject selector: aSymbol argument: aParameter [
	^ self receiver: anObject selector: aSymbol arguments: (Array with: aParameter)
]

{ #category : #all }
MessageSend class >> receiver: anObject selector: aSymbol arguments: anArray [
	^ self new
		receiver: anObject;
		selector: aSymbol;
		arguments: anArray
]

{ #category : #all }
MessageSend >> = anObject [
	^ anObject species == self species 
		and: [receiver == anObject receiver
		and: [selector == anObject selector
		and: [arguments = anObject arguments]]]
]

{ #category : #all }
MessageSend >> arguments [
	^ arguments
]

{ #category : #all }
MessageSend >> arguments: anArray [
	arguments := anArray
]

{ #category : #all }
MessageSend >> collectArguments: anArgArray [
	"Private"

    | staticArgs |
    staticArgs := self arguments.
    ^(anArgArray size = staticArgs size)
        ifTrue: [anArgArray]
        ifFalse:
            [(staticArgs isEmpty
                ifTrue: [ staticArgs := Array new: selector numArgs]
                ifFalse: [staticArgs copy] )
                    replaceFrom: 1
                    to: (anArgArray size min: staticArgs size)
                    with: anArgArray
                    startingAt: 1]
]

{ #category : #all }
MessageSend >> cull: arg [
	^ selector numArgs = 0 
		ifTrue: [ self value ]
		ifFalse: [ self value: arg ].

	
]

{ #category : #all }
MessageSend >> cull: arg1 cull: arg2 [
	^ selector numArgs < 2 
		ifTrue: [ self cull: arg1]
		ifFalse: [ self value: arg1 value: arg2 ]
]

{ #category : #all }
MessageSend >> cull: arg1 cull: arg2 cull: arg3 [
	^ selector numArgs < 3 
		ifTrue: [ self cull: arg1 cull: arg2 ]
		ifFalse: [ self value: arg1 value: arg2 value: arg3 ]
]

{ #category : #all }
MessageSend >> hash [
	^ receiver hash bitXor: selector hash
]

{ #category : #all }
MessageSend >> message [
	^Message selector: selector arguments: arguments
]

{ #category : #all }
MessageSend >> numArgs [
	"Answer the number of arguments in this message"

	^arguments size
]

{ #category : #all }
MessageSend >> receiver [
	^ receiver
]

{ #category : #all }
MessageSend >> receiver: anObject [
	receiver := anObject
]

{ #category : #all }
MessageSend >> selector [
	^ selector
]

{ #category : #all }
MessageSend >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #all }
MessageSend >> value [
  "Send the message and answer the return value"

  arguments ifNil: [^ receiver perform: selector].

  ^ receiver 
    perform: selector 
    withArguments: (self collectArguments: arguments)
]

{ #category : #all }
MessageSend >> value: anObject [

  ^ receiver 
    perform: selector 
    with: anObject
]

{ #category : #all }
MessageSend >> value: anObject1 value: anObject2 [

	^ receiver 
		perform: selector 
		with: anObject1
		with: anObject2
]

{ #category : #all }
MessageSend >> value: anObject1 value: anObject2 value: anObject3 [

	^ receiver 
		perform: selector 
		with: anObject1
		with: anObject2
		with: anObject3
]

{ #category : #all }
MessageSend >> valueWithArguments: anArray [

	^ receiver 
		perform: selector 
		withArguments: (self collectArguments: anArray)
]

{ #category : #all }
MessageSend >> cpEncodeWith: anEncoder [

	anEncoder encodeMessageSend: self
]
