Class {
	#name : #CpMessageChannel,
	#superclass : #Object,
	#instVars : [
		'owner'
	],
	#classVars : [
		'EnvironmentImplementation'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpMessageChannel class >> environmentImplementation [

	"Answer the Class which performs the receiver's behavior on the current environment.
	Implementation: A specific implementation can be set, otherwise a sole subclass will indicate
	that implementation should be used. In all other situations answer nil, meaning 'undecided'."

	^ EnvironmentImplementation
		ifNil: [
			self = CpMessageChannel
				ifTrue: [
					| implementationClasses |

					"If a single subclass exists use that, otherwise answer nil to denote 'undecided'"
					implementationClasses := self allSubclasses.
					implementationClasses size = 1
						ifTrue: [ implementationClasses asArray first ] ]
				ifFalse: [ self ] ]
]

{ #category : #all }
CpMessageChannel class >> environmentImplementation: aClass [

	"Set the Class which performs the receiver's behavior on the current environment"

	EnvironmentImplementation := aClass
]

{ #category : #all }
CpMessageChannel class >> forOwner: ownerObject connectedToUrl: urlString [

	"Create for the specified owner, a new instance of the receiver which is connected
	to the specified URL.
	The instance can be used directly to send (or receive) messages.
	Answer nil if a connection failed."

	"Use the environment's specific implementation or raise an error"
	self environmentImplementation
		ifNotNil: [ :implementationClass | ^ implementationClass forOwner: ownerObject connectedToUrl: urlString ]
		ifNil: [ Error signal: 'No implementation class set for MessageChannel' ]
]

{ #category : #all }
CpMessageChannel class >> startServerForOwner: ownerObject onPort: anInteger path: aString [

	"Create a server listening on the specified port and path for the specified owner.
	The owner Object will need to handle the relevant events. See #owner:."

	"Use the environment's specific implementation or raise an error"
	self environmentImplementation
		ifNotNil: [ :implementationClass |
			^ implementationClass startServerForOwner: ownerObject onPort: anInteger path: aString ]
		ifNil: [ Error signal: 'No implementation class set for MessageChannel' ]
]

{ #category : #all }
CpMessageChannel >> close [

	"Close the receiver, thereby making the receiver unusable"

	self subclassResponsibility
]

{ #category : #all }
CpMessageChannel >> createMessageHandler [

	"Create a forked process which will run the receiver's message handler for messages received"
	[ self runMessageHandler ] forkAt: Processor highIOPriority named: 'MessageHandler'
]

{ #category : #all }
CpMessageChannel >> handleMessageHandlerError: anError [ 

	"Placeholder method to allow specific error handling by subclass or extension method."

	self errorCr: 'Failed to handle messages: ' , anError printString
]

{ #category : #all }
CpMessageChannel >> handleMessageReceived: aByteArray [

	"Let the owner handle the message received.
	If the receiver is closed (aByteArray will be nil) then also make the channel argument nil.
	Implementation: Make sure our owner is still valid, since it can be nil if the receiver is released."

	self owner ifNotNil: [ :anObject |
		anObject
			handleMessageReceived: aByteArray
			on: (aByteArray ifNotNil: [ self ]) ]
]

{ #category : #all }
CpMessageChannel >> handleMessages [

	"Handle received messages as long as they are available"

	[ self handleNextMessage ] whileTrue
]

{ #category : #all }
CpMessageChannel >> handleNextMessage [

	"Let the receiver's owner handle the next message received (if available) and
	answer a Boolean indicating if such message was available"

	| messageByteArray |

	messageByteArray := self receivedMessage ifNil: [ ^ false ].

	self handleMessageReceived: messageByteArray.

	^ true

]

{ #category : #all }
CpMessageChannel >> initializeWithOwner: ownerObject [

	"Initialize the receiver with the specified owner.
	The owner should accept the message #handleMessageReceived:on: which receives a
	message as the first argument and the receiver as the second argument.
	When the receiver is closed, the above message is sent to the owner with nil as
	argument for both message and message channel to indicate the connection has closed."

	self initialize.

	owner := ownerObject
]

{ #category : #all }
CpMessageChannel >> isOpen [

	"Answer whether the receiver is open (ie can send and receive messages)"

	self subclassResponsibility
]

{ #category : #all }
CpMessageChannel >> owner [

	"Answer the receiver's owner"

	^ owner
]

{ #category : #all }
CpMessageChannel >> receivedMessage [

	"Answer the next message received or nil if none is available"

	self subclassResponsibility
]

{ #category : #all }
CpMessageChannel >> release [

	"Release the receiver's instance variables"

	owner := nil.

	super release
]

{ #category : #all }
CpMessageChannel >> runMessageHandler [

	"Run the receiver's message handling process for handling received messages.
	Implementation: After the connection has closed, clean up."
	[ self isOpen ] whileTrue: [
		[ 
			"Handle available messages and update internal state"
			self
				handleMessages ;
				updateState
		 ] on: Error do: [ :error | 
			self handleMessageHandlerError: error ] ].

	"Signal connection is closed by sending a nil message"
	self handleMessageReceived: nil.

	self release
]

{ #category : #all }
CpMessageChannel >> sendMessage: aByteArray [

	"Send the specified message.
	An Exception should be thrown if sending failed."

	self subclassResponsibility
]

{ #category : #all }
CpMessageChannel >> updateState [

	"Update the receiver's state.
	Implementation: Empty method, subclasses may add behavior"
]
