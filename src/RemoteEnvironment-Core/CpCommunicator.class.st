Class {
	#name : #CpCommunicator,
	#superclass : #Object,
	#instVars : [
		'owner',
		'unsentMessages',
		'unsentMessagesMutex',
		'messageChannel'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpCommunicator class >> newForOwner: ownerObject [

	"Answer a new instance of the receiver for the specified owner.
	The owner is responsible for handling the message received and should therefore
	accept the message: #handleMessageReceived:"

	^ self basicNew
		initializeWithOwner: ownerObject ;
		yourself
]

{ #category : #all }
CpCommunicator >> basicSendMessage: aByteArray [

	"Send message to the server and answer whether send is successful"

	self hasOpenMessageChannel
		ifFalse: [ ^ false ].

	[ self messageChannel sendMessage: aByteArray ] on: Error do: [ ^ false ].

	^ true
]

{ #category : #all }
CpCommunicator >> close [

	"Disconnect from the server"

	self hasMessageChannel ifFalse: [ ^ self ].

	"Since MessageChannels are unusable after close, release it after close"
	self messageChannel close.
	self releaseMessageChannel
]

{ #category : #all }
CpCommunicator >> handleMessageReceived: aByteArray on: aMessageChannel [

	"Let the owner handle the message received"

	"The receiver's MessageChannel will be closed if the specified MessageChannel is nil"
	self messageChannel: aMessageChannel.

	aByteArray ifNotNil: [ self owner handleMessageReceived: aByteArray ]
]

{ #category : #all }
CpCommunicator >> hasMessageChannel [

	"Answer whether the receiver has a MessageChannel (irrespective of its connection state)"

	^ messageChannel notNil
]

{ #category : #all }
CpCommunicator >> hasOpenMessageChannel [

	"Answer whether the receiver has a MessageChannel which is open (ie can send and receive messages)"

	^ messageChannel notNil and: [ messageChannel isOpen ]
]

{ #category : #all }
CpCommunicator >> hasUnsentMessages [

	^ self unsentMessagesCount > 0
]

{ #category : #all }
CpCommunicator >> initialize [

	"Initialze the receiver"

	super initialize.

	unsentMessages := OrderedCollection new.
	unsentMessagesMutex := Mutex new
]

{ #category : #all }
CpCommunicator >> initializeWithOwner: ownerObject [

	"Initialize the receiver with the specified owner.
	The owner is responsible to handle the messages received by the receiver.
	Therefore ownerObject should accept the message: #handleMessageReceived:"

	self initialize.

	owner := ownerObject
]

{ #category : #all }
CpCommunicator >> messageChannel [

	"Answer the receiver's MessageChannel"

	^ messageChannel
]

{ #category : #all }
CpCommunicator >> messageChannel: aMessageChannel [

	"Set the receiver's MessageChannel. If nil the existing MessageChannel closed.
	Implementation: MessageChannels become unusable after closing and new instances might need to be
	set on the receiver. Release the old MessageChannel instance explicitly before setting the new one,
	to allow resources to be released."

	messageChannel = aMessageChannel
		ifTrue: [ ^ self ].

	self releaseMessageChannel.

	(messageChannel := aMessageChannel)
		ifNotNil: [ self sendUnsentMessages ]
]

{ #category : #all }
CpCommunicator >> owner [

	"Answer the owner of the receiver"

	^ owner
]

{ #category : #all }
CpCommunicator >> release [

	"Release the receiver's instance variables"

	self releaseMessageChannel.

	unsentMessagesMutex := nil.
	unsentMessages := nil.

	owner := nil.

	super release
]

{ #category : #all }
CpCommunicator >> releaseMessageChannel [

	"Release the receiver's MessageChannel.
	Implementation: Release the channel explicitly to free up resources."

	messageChannel ifNil: [ ^ self ].

	messageChannel release.
	messageChannel := nil
]

{ #category : #all }
CpCommunicator >> sendFirstUnsentMessage [

	"Send the first unsent message. Answer whether send is successful.
	If message can't be sent, keep it as first unsent message."

	unsentMessagesMutex critical: [
		| firstUnsentMessage |

		unsentMessages ifEmpty: [ ^ false ].

		firstUnsentMessage := unsentMessages removeFirst.
		(self basicSendMessage: firstUnsentMessage)
			ifFalse: [
				unsentMessages addFirst: firstUnsentMessage.
				^ false ].

		^ true ]
]

{ #category : #all }
CpCommunicator >> sendMessage: aByteArray [

	"Send message to the server. Store message if sending failed."
	unsentMessagesMutex critical: [
			"If no other messages are pending, try to send message"
			unsentMessages
				ifEmpty: [
					(self basicSendMessage: aByteArray)
						ifTrue: [ ^ self ] ].

			"Add message to end of the collection of unsent messages"
			unsentMessages add: aByteArray ]
]

{ #category : #all }
CpCommunicator >> sendUnsentMessages [

	"Send all unsent messages in order"

	[ self sendFirstUnsentMessage ] whileTrue

]

{ #category : #all }
CpCommunicator >> unsentMessagesByteSize [

	"Answer the number of bytes inside the unsent messages of the receiver"

	unsentMessagesMutex critical: [
		^ unsentMessages inject: 0 into: [ :sum :each | sum + each size ] ]
]

{ #category : #all }
CpCommunicator >> unsentMessagesCount [

	"Answer the number of unsent messages in the receiver"

	unsentMessagesMutex critical: [ ^ unsentMessages size ]
]
