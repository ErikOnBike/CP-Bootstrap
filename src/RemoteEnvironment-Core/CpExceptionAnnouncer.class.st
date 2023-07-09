Class {
	#name : #CpExceptionAnnouncer,
	#superclass : #Announcer,
	#classVars : [
		'Current'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpExceptionAnnouncer class >> current [

	"Answer the current instance of the receiver"

	^ Current ifNil: [ Current := self basicNew initialize ; yourself ]
]

{ #category : #all }
CpExceptionAnnouncer class >> new [

	"Use self >> #current instead to get the singleton instance"

	self shouldNotImplement
]

{ #category : #all }
CpExceptionAnnouncer class >> announce: anAnnouncement [

	"In case no one is listening, simply answer nil and do not create my current instance"
	self hasCurrent
		ifFalse: [ ^ nil ].

	^ self current
		announce: anAnnouncement
]

{ #category : #all }
CpExceptionAnnouncer class >> announceException: anException [

	"In case no one is listening, simply answer nil and do not create announcement or my current instance"
	self hasCurrent
		ifFalse: [ ^ nil ].

	^ self announce: (CpExceptionAnnouncement exception: anException)
]

{ #category : #all }
CpExceptionAnnouncer class >> when: anAnnouncement send: aSymbol to: anObject [

	^ self current
		when: anAnnouncement send: aSymbol to: anObject
]

{ #category : #all }
CpExceptionAnnouncer class >> when: anAnnouncement do: aBlock [

	^ self current
		when: anAnnouncement do: aBlock
]

{ #category : #all }
CpExceptionAnnouncer class >> hasCurrent [
	^ Current isNotNil
]
