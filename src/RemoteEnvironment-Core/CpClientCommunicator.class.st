Class {
	#name : #CpClientCommunicator,
	#superclass : #CpCommunicator,
	#instVars : [
		'url',
		'reconnectStrategy'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpClientCommunicator >> checkConnection [

	"Check connection and restore connection if needed, according to receiver's reconnect strategy"

	(self hasOpenMessageChannel or: [ self hasReconnectStrategy not ])
		ifTrue: [ ^ self ].

	"Reconnect according to the receiver's reconnect strategy"
	(self reconnectStrategy shouldReconnect: self)
		ifTrue: [ self reconnect ]
]

{ #category : #all }
CpClientCommunicator >> connectToUrl: urlString [

	"Make a new connection to the specified server. Users of this method should afterwards
	check whether the receiver has an open connection using #hasOpenConnection to check if
	connection was successful."

	self close.

	url := urlString.
	self messageChannel: (CpMessageChannel for: self connectedToUrl: url)
]

{ #category : #all }
CpClientCommunicator >> hasReconnectStrategy [

	"Answer whether the receiver has a reconnect strategy"

	^ reconnectStrategy notNil
]

{ #category : #all }
CpClientCommunicator >> initialize [

	super initialize.

	"By default always use reconnect strategy"
	self reconnectStrategy: CpCommunicatorReconnectStrategy new
]

{ #category : #all }
CpClientCommunicator >> messageChannel: aMessageChannel [

	"Set the receiver's MessageChannel. If nil the existing MessageChannel closed."

	super messageChannel: aMessageChannel.

	aMessageChannel ifNil: [ self checkConnection ]
]

{ #category : #all }
CpClientCommunicator >> reconnect [

	"Reconnect the receiver to the previous URL"

	self connectToUrl: self url.

	"Let the server know on which WebSocket we reconnected by restarting communication"
	CpClientEnvironment current restartCommunication
]

{ #category : #all }
CpClientCommunicator >> reconnectStrategy [

	"Answer the receiver's reconnect strategy"

	^ reconnectStrategy
]

{ #category : #all }
CpClientCommunicator >> reconnectStrategy: aReconnectStrategy [

	"Set the receiver's reconnect strategy"

	reconnectStrategy := aReconnectStrategy
]

{ #category : #all }
CpClientCommunicator >> release [

	"Release the receiver's instance variables"

	reconnectStrategy := nil.
	url := nil.

	super release
]

{ #category : #all }
CpClientCommunicator >> sendMessage: aByteArray [

	"Send message to the server, reconnecting if required."
	
	"Implementation:
	Order is important. The message is first sent and will, in case of a lost connection,
	result in an unsent message. My reconnect strategy can then make use of this fact
	(presence of unsent messages) to decide if a reconnect is required."

	super sendMessage: aByteArray.

	self checkConnection
]

{ #category : #all }
CpClientCommunicator >> url [

	"Answer the URL (a String) the receiver is (or should be) connected to"

	^ url
]
