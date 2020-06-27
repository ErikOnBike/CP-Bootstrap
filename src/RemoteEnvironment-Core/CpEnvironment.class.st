Class {
	#name : #CpEnvironment,
	#superclass : #Object,
	#instVars : [
		'id',
		'communicator'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpEnvironment class >> communicatorClass [

	"Answer the Communicator Class for the receiver"

	self subclassResponsibility
]

{ #category : #all }
CpEnvironment >> communicator [

	"Answer the receiver's communicator"

	^ communicator
]

{ #category : #all }
CpEnvironment >> communicator: aCommunicator [

	"Set the receiver's Communicator"

	communicator := aCommunicator
]

{ #category : #all }
CpEnvironment >> createCommunicator [

	"Create a new communicator for the receiver and answer it"

	^ self class communicatorClass newFor: self
]

{ #category : #all }
CpEnvironment >> handleMessageReceived: aByteArray [

	"Handle the message received"

	self subclassResponsibility
]

{ #category : #all }
CpEnvironment >> hasCommunicator [

	"Answer whether the receiver has a Communicator setup"

	^ communicator notNil
]

{ #category : #all }
CpEnvironment >> id [

	"Answer the receivers identifier (a String)"

	^ id
]

{ #category : #all }
CpEnvironment >> id: identifier [

	"Set the identifier of the receiver"

	id := identifier
]

{ #category : #all }
CpEnvironment >> release [

	"Release the receiver's instance variables"

	communicator ifNotNil: [
		communicator close.
		communicator := nil ].

	id := nil.

	super release
]

{ #category : #all }
CpEnvironment >> sendMessage: aByteArray [

	"Send (encoded) message to the server"

	self hasCommunicator ifFalse: [ ^ self ].

	self communicator sendMessage: aByteArray
]

{ #category : #all }
CpEnvironment >> startCommunication [

	"Start communication with the other party"

	self communicator: self createCommunicator
]

{ #category : #all }
CpEnvironment >> stopCommunication [

	"Stop communication with server"

	self hasCommunicator ifFalse: [ ^ self ].

	self communicator close
]
