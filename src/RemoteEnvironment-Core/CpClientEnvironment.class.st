Class {
	#name : #CpClientEnvironment,
	#superclass : #CpEnvironment,
	#instVars : [
		'objectRegistry'
	],
	#classVars : [
		'Current',
		'PreInstalledClasses'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpClientEnvironment class >> communicatorClass [

	^ CpClientCommunicator
]

{ #category : #all }
CpClientEnvironment class >> current [

	"Answer the current instance of the receiver"

	^ Current ifNil: [ Current := self basicNew initialize ]
]

{ #category : #all }
CpClientEnvironment class >> isRunning [

	"Answer whether the ClientEnvironment is running/active"

	^ Current notNil
]

{ #category : #all }
CpClientEnvironment class >> hasPreInstalledClass: aClass [

	"Answer whether the specified Class is pre-installed in the receiver"

	^ self preInstalledClasses includes: aClass
]

{ #category : #all }
CpClientEnvironment class >> new [

	"Use self >> #current instead to get the singleton instance"

	self shouldNotImplement
]

{ #category : #all }
CpClientEnvironment class >> preInstalledClasses [

	"Answer the Classes which are pre-installed in the receiver (image/environment)"

	^ PreInstalledClasses ifNil: [
		PreInstalledClasses := Set new
			add: CpClientEnvironment ;
			add: CpClientCommunicator ;
			add: CpJavascriptWebSocketChannel ;
			add: CpObjectDecoder ;
			add: CpObjectEncoder ;
			add: Announcement ;
			add: AnnouncementDeliveryCondition ;
			add: AnnouncementSet ;
			add: AnnouncementSetWithExclusions ;
			add: CpClientStarted ;
			add: ProtoObject ;
			add: Object ;
			add: UndefinedObject ;
			add: Array ;
			add: ByteArray ;
			add: Collection ;
			add: ArrayedCollection ;
			add: SequenceableCollection ;
			add: OrderedCollection ;
			add: Dictionary ;
			add: IdentityDictionary ;
			add: Set ;
			add: IdentitySet ;
			add: Association ;
			add: ValueLink ;
			add: LinkedList ;
			add: Interval ;
			add: String ;
			add: Symbol ;
			add: Magnitude ;
			add: Number ;
			add: SmallInteger ;
			add: Integer ;
			add: LargePositiveInteger ;
			add: LargeNegativeInteger ;
			add: Float ;
			add: Character ;
			add: True ;
			add: False ;
			add: Process ;
			add: Semaphore ;
			add: Mutex ;
			add: Context ;
		yourself ]
]

{ #category : #all }
CpClientEnvironment class >> release [

	"Release the receiver, resetting all Class variables"

	Current := nil.
	PreInstalledClasses := nil
]

{ #category : #all }
CpClientEnvironment class >> installReconnectStrategy: aReconnectStrategy [

	self current communicator
		reconnectStrategy: aReconnectStrategy
]

{ #category : #all }
CpClientEnvironment class >> variableNameApp [

	^ #APP
]

{ #category : #all }
CpClientEnvironment >> alert: aString [

	"Alert user with specified message (please use sparsely)"

	<primitive: 'primitiveEnvironmentAlert:' module: 'CpSystemPlugin'>
	^ self

]

{ #category : #all }
CpClientEnvironment >> confirm: aString [

	"Confirm specified message with user (please use sparsely)"

	<primitive: 'primitiveEnvironmentConfirm:' module: 'CpSystemPlugin'>
	^ false

]

{ #category : #all }
CpClientEnvironment >> createCommunicator [

	"Create a new communicator for the receiver which is connected to the server
	and answer it"

	^ super createCommunicator
		connectToUrl: self serverUrl ;
		yourself
]

{ #category : #all }
CpClientEnvironment >> createInstanceOf: className withId: identifier [

	"Create an instance of the specified Class and register it in the receiver's
	object registry under the given identifier. Answer the newly created instance.

	Implementation:
	Create instance without initialization, register it and then perform initialization.
	The initialization code of the instance can then make use of the instance's id,
	which it can retrieve by querying the receiver's object registry."

	| class instance |

	class := (Smalltalk classNamed: className) ifNil: [ self error: 'Unknown class ', className printString ].
	instance :=  class basicNew.
	self objectRegistry registerObject: instance withId: identifier.
	instance initialize.

	^ instance
]

{ #category : #all }
CpClientEnvironment >> globalApply: aSymbol withArguments: anArray [

	"Perform the specified symbol on the global scope (ie 'window' in the browser
	environment) with the specified arguments"

	<primitive: 'primitiveEnvironmentGlobalApply:withArguments:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
CpClientEnvironment >> removeSession [

	self removeVariableAt: #CLIENT_ID
]

{ #category : #all }
CpClientEnvironment >> invalidSession [

	"An invalid session is encountered, ask user whether to start new session"

	(self confirm: 'The session is invalid. Start new session?')
		ifFalse: [ ^ self ].

	"Reset client identifier and (fully) reload"
	self
		removeSession ;
		reload
]

{ #category : #all }
CpClientEnvironment >> reload [

	"Reload the receiver (changes might get lost, use sparsely)"

	<primitive: 'primitiveEnvironmentReload' module: 'CpSystemPlugin'>
	^ self
]

{ #category : #all }
CpClientEnvironment >> exit [

	"Stop execution.
	I will reset my id, so I will not be 'reloadable'."

	self
		stopCommunication ;
		removeSession ;
		release
]

{ #category : #all }
CpClientEnvironment >> fatal: aString [

	"Signal a fatal situation has occurred.
	Inform the user of this fatality, since this situation can't be handled by the receiver anymore."

	self alert: 'FATAL: ', aString
]

{ #category : #all }
CpClientEnvironment >> handleMessageReceived: aByteArray [

	"Handle (encoded) message received through the receiver's communicator.
	Implementation: A message consists of an Array of selector/arguments pairs
	to perform on the receiver."

	| decoder |

	decoder := CpObjectDecoder on: aByteArray.

	[ decoder hasMoreData ] whileTrue: [

		| messageSend |
		messageSend := [ decoder decodeNext ] on: Error do: [ :error |

			"Announce error and stop handling the message"
			self serverAnnounce: (CpClientDecodeFailed description: error description).
			^ self ].

		self handleMessageSend: messageSend ]
]

{ #category : #all }
CpClientEnvironment >> handleMessageSend: aMessageSend [

	"Perform the MessageSend assuming the MessageSend's receiver is encoded as
	either nil, indicating the ClientEnvironment as receiver
	or an identifier, indicating an Object registered"

	| receiverId |

	(receiverId := aMessageSend receiver)
		ifNotNil: [
			(self objectRegistry objectWithId: receiverId)
				ifNotNil: [ :object | aMessageSend receiver: object ]
				ifNil: [
					"Send Announcement of error to server"
					self serverAnnounce: (CpClientMessageSendFailed
						messageSend: aMessageSend
						description: 'Object with the specified id does not exist in the client').
					^ self ] ]
		ifNil: [ aMessageSend receiver: self ].

	"Perform the message send"
	[ aMessageSend value ] on: Error do: [ :error |

		self crError: 'Error when sent message ', aMessageSend selector, ' to ', aMessageSend receiver printString.
		self crError: error printString.
		self crError: error signalerContext printString.

		"Restore receiver id and send Announcement of error to server"
		aMessageSend receiver: receiverId.
		self serverAnnounce: (CpClientMessageSendFailed
			messageSend: aMessageSend
			description: error description) ]
]

{ #category : #all }
CpClientEnvironment >> id: identifier [

	"Set the identifier of the receiver. Register this identifier (persistently) for later usage
	when the receiver needs reloading/restarting."

	super id: identifier.

	self variableAt: #CLIENT_ID put: identifier
]

{ #category : #all }
CpClientEnvironment >> initialize [

	"Initialize the receiver with the previously registered/persisted identifier (if any)"

	super initialize.

	id := self variableAt: #CLIENT_ID.

	objectRegistry := CpObjectRegistry new
]

{ #category : #all }
CpClientEnvironment >> installClass: aClass [

	"Install (decoded) Class"

	"Only perform post installation initialization here.
	Class is already installed in CpObjectDecoder during decoding
	otherwise no class could be answered as part of the decoding."
	self crTrace: 'Installed class ', aClass name.
	aClass postInstall
]

{ #category : #all }
CpClientEnvironment >> installMethod: aCompiledMethod [

	"Install (decoded) CompiledMethod"
	aCompiledMethod install

]

{ #category : #all }
CpClientEnvironment >> log: aString [

	"Log message on Transcript/console"

	<primitive: 'primitiveEnvironmentLog:' module: 'CpSystemPlugin'>
	^ self
]

{ #category : #all }
CpClientEnvironment >> warn: aString [

	"Log warning message on Transcript/console"

	<primitive: 'primitiveEnvironmentWarn:' module: 'CpSystemPlugin'>
	^ self
]

{ #category : #all }
CpClientEnvironment >> error: aString [

	"Log error message on Transcript/console"

	<primitive: 'primitiveEnvironmentError:' module: 'CpSystemPlugin'>
	^ self
]

{ #category : #all }
CpClientEnvironment >> objectRegistry [

	"Answer the receiver's object registry. The registry is needed for the server
	to be able to address individual objects in the receiver."

	^ objectRegistry
]

{ #category : #all }
CpClientEnvironment >> release [

	"Release instance variables"

	objectRegistry := nil.

	super release
]

{ #category : #all }
CpClientEnvironment >> serverAnnounce: anAnnouncement [

	"Send the specified Announcement back to the server"

	self sendEncodedMessage: (CpObjectEncoder new
		encode: id ;
		encode: anAnnouncement ;
		bytes)
]

{ #category : #all }
CpClientEnvironment >> serverUrl [

	"Answer the URL (as a String) of the server environment.
	The environment variable #SERVER_URL should provide this information."

	^ (self variableAt: #SERVER_URL)
		ifNil: [ self fatal: 'The environment variable #SERVER_URL is not properly set' ]
]

{ #category : #all }
CpClientEnvironment >> app [

	"Answer a Symbol identifying the application that is running.
	The app environment variable should provide this information."

	^ (self variableAt: self class variableNameApp)
		ifNotNil: [ :appString | appString asSymbol ]
		ifNil: [ self fatal: 'The environment variable ' , self class variableNameApp printString , ' is not properly set' ]
]

{ #category : #all }
CpClientEnvironment >> startCommunication [

	"Start communication with server"

	super startCommunication.

	"Send initial event to server to actually start communication"
	self serverAnnounce: (CpClientStarted variables: self variables)
]

{ #category : #all }
CpClientEnvironment >> stopCommunication [

	"Stop communication with server"

	self serverAnnounce: CpClientStopped new.

	super stopCommunication
]

{ #category : #all }
CpClientEnvironment >> variableNames [

	"Answer an array with the names of available environment variables."

	<primitive: 'primitiveEnvironmentVariableNames' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
CpClientEnvironment >> variables [

	"Answer a dictionary with the names and values of available environment variables."

	| variables |

	variables := Dictionary new.

	self variableNames do: [ :each | 
		variables at: each put: (self variableAt: each) ].

	^ variables
]

{ #category : #all }
CpClientEnvironment >> variableAt: nameString [

	"Answer the value (a String) of the environment variable with the specified name
	or nil if a variable with the specified name does not exist.
	Case sensitivity is not defined, for compatibility best use all uppercase names."

	<primitive: 'primitiveEnvironmentVariableAt:' module: 'CpSystemPlugin'>
	^ nil
]

{ #category : #all }
CpClientEnvironment >> variableAt: nameString put: valueString [

	"Set the environment variable with the specified name to the specified value.
	Case sensitivity is not defined, for compatibility best use all uppercase names."


	<primitive: 'primitiveEnvironmentVariableAt:put:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
CpClientEnvironment >> removeVariableAt: nameString [

	"Remove the environment variable with the specified name.
	Case sensitivity is not defined, for compatibilty best use all uppercase names."

	<primitive: 'primitiveEnvironmentRemoveVariableAt:' module: 'CpSystemPlugin'>
	^ self
]

{ #category : #all }
CpClientEnvironment >> persistentVariableAt: nameString [

	"Answer the value (a String) of the persisted environment variable with the specified name
	or nil if a variable with the specified name does not exist.
	Persisted variables will, in contrast with regular variables, survive beyond the session lifetime."

	<primitive: 'primitiveEnvironmentPersistentVariableAt:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
CpClientEnvironment >> persistentVariableAt: nameString put: valueString [

	"Set the persisted environment variable with the specified name to the specified value.
	Persisted variables will, in contrast with regular variables, survive beyond the session lifetime.
	Case sensitivity is not defined, for compatibilty best use all uppercase names."

	<primitive: 'primitiveEnvironmentPersistentVariableAt:put:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
CpClientEnvironment >> removePersistentVariableAt: nameString [

	"Remove the persisted environment variable with the specified name.
	Persisted variables will, in contrast with regular variables, survive beyond the session lifetime.
	Case sensitivity is not defined, for compatibilty best use all uppercase names."

	<primitive: 'primitiveEnvironmentRemovePersistentVariableAt:' module: 'CpSystemPlugin'>
	^ self
]
