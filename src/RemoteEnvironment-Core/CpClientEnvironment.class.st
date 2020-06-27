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
CpClientEnvironment >> alert: aString [

	"Alert user with specified message (please use sparsely)"

	self primAlert: aString

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
CpClientEnvironment >> exit [

	"Stop execution.
	I will reset my id, so I will not be 'reloadable'."

	self
		stopCommunication ;
		variableAt: #CLIENT_ID put: nil.

	self release
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

	receiverId := aMessageSend receiver.
	aMessageSend receiver: (receiverId
		ifNotNil: [ self objectRegistry objectWithId: receiverId ]
		ifNil: [ self ]).

	"Perform the message send"
	[ aMessageSend value ] on: Error do: [ :error |

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
System log: 'Installed class ', aClass name.
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

	self primLog: aString

]

{ #category : #all }
CpClientEnvironment >> objectRegistry [

	"Answer the receiver's object registry. The registry is needed for the server
	to be able to address individual objects in the receiver."

	^ objectRegistry
]

{ #category : #all }
CpClientEnvironment >> primAlert: aString [

	<primitive: 'primitiveEnvironmentAlert:' module: 'CpSystemPlugin'>
	^ self

]

{ #category : #all }
CpClientEnvironment >> primLog: aString [

	<primitive: 'primitiveLog:' module: 'CpSystemPlugin'>
	^ self

]

{ #category : #all }
CpClientEnvironment >> release [

	"Release instance variables"

	objectRegistry := nil.

	super release
]

{ #category : #all }
CpClientEnvironment >> serverAnnounce: anAnnouncement [

	"Send the specified Announcement back to the server by encoding it as a message.
	Implementation: The message sent to the server will also contain the
	receiver's id for identification of the environment at the server side."

	self sendMessage: (CpObjectEncoder new
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

	"Answer a String identifying the application that is running.
	The environment variable #APP should provide this information."

	^ (self variableAt: #APP)
		ifNil: [ self fatal: 'The environment variable #APP is not properly set' ]
]

{ #category : #all }
CpClientEnvironment >> startCommunication [

	"Start communication with server"

	super startCommunication.

	"Send initial event to server to actually start communication"
	self serverAnnounce: (CpClientStarted app: self app)
]

{ #category : #all }
CpClientEnvironment >> stopCommunication [

	"Stop communication with server"

	self serverAnnounce: CpClientStopped new.

	super stopCommunication
]

{ #category : #all }
CpClientEnvironment >> variableAt: nameString [

	"Answer the value (a String) of the environment variable with the specified name
	or nil if a variable with the specified name does not exist"

	<primitive: 'primitiveEnvironmentVariableAt:' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
CpClientEnvironment >> variableAt: nameString put: valueString [

	"Set the environment variable with the specified name to the specified value.
	Case sensitivity is not defined, for compatibilty best use all uppercase names."

	<primitive: 'primitiveEnvironmentVariableAt:put:' module: 'CpSystemPlugin'>
	self primitiveFailed
]
