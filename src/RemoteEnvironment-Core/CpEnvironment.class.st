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
CpEnvironment >> createCommunicator [

	"Create a new communicator for the receiver and answer it"

	^ communicator := self class communicatorClass newForOwner: self
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
CpEnvironment >> ifDevelopment: aBlock [

	"Evaluate the specified Block if running in a development environment (i.e. non-production environment)"

	self ifProduction: [ "intentionally empty" ] ifDevelopment: aBlock
]

{ #category : #all }
CpEnvironment >> ifProduction: prodBlock ifDevelopment: devBlock [

	"Evaluate the appropriate Block depending on the environment status"

	(self variableAt: #'CODE_PARADISE_ENV') = 'production'
		ifTrue: [ prodBlock value ]
		ifFalse: [ devBlock value ]
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
CpEnvironment >> sendEncodedMessage: aByteArray [

	"Send encoded message to the connected party"

	self hasCommunicator ifFalse: [ ^ self ].

	self communicator sendMessage: aByteArray
]

{ #category : #all }
CpEnvironment >> sendMessage: aByteArray [

	"Send the specified MessageSend to the server"

	self sendEncodedMessage: aMessageSend cpEncoded
]

{ #category : #all }
CpEnvironment >> startCommunication [

	"Start communication with the other party"

	self createCommunicator
]

{ #category : #all }
CpEnvironment >> stopCommunication [

	"Stop communication with server"

	self hasCommunicator ifFalse: [ ^ self ].

	self communicator close
]
