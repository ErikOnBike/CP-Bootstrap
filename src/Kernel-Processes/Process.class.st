Class {
	#name : #Process,
	#superclass : #Object,
	#instVars : [
		'nextLink',
		'suspendedContext',
		'priority',
		'myList',
		'name'
	],
	#category : #'Kernel-Processes'
}

{ #category : #all }
Process class >> forContext: aContext priority: anInteger [
	"Answer an instance of me for the given context (usually a Block) at the given priority."

	^ self new
		initSuspendedContext: aContext;
		priority: anInteger
]

{ #category : #all }
Process >> initSuspendedContext: aContext [
	suspendedContext := aContext.
	priority := 1	"lowest priority"
]

{ #category : #all }
Process >> nextLink [
	^ nextLink
]

{ #category : #all }
Process >> nextLink: aLink [
	nextLink := aLink
]

{ #category : #all }
Process >> name [
	^ name
]

{ #category : #all }
Process >> name: aString [
	name := aString
]

{ #category : #all }
Process >> printOn: aStream [
	super printOn: aStream.
	name ifNotNil: [ aStream nextPutAll: ' (' ; nextPutAll: name ; nextPut: $) ].
	aStream nextPutAll: ' in '.
	suspendedContext printOn: aStream
]

{ #category : #all }
Process >> priority [
	"Answer the priority of the receiver."

	^ priority
]

{ #category : #all }
Process >> priority: anInteger [
	"Set the receiver's priority to anInteger. The priority is used by the VM as an index into the scheduler's array of process queues so it must be an integer between 1 and Processor highestPriority."

	priority := (anInteger asInteger max: 1)
		min: Processor highestPriority
]

{ #category : #all }
Process >> resume [
	"Primitive. Allow this process to proceed. Put the receiver in line to become the active process. Fail if the receiver is already waiting on a queue (i.e., on a Semaphore or on a scheduler queue). Essential. See Object documentation whatIsAPrimitive."

	<primitive: 87>
	self primitiveFailed
]

{ #category : #all }
Process >> suspend [
	"Primitive. Stop this process in such a way that it can be restarted later (see resume). If the receiver is the active process, suspend it. Otherwise, remove the receiver from its suspended process list. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 88>
	Processor activeProcess == self
		ifTrue: [ self primitiveFailed ]
		ifFalse: [ Processor
				remove: self
				ifAbsent: [ self error: 'This process was not active' ].
			myList := nil ]
]

{ #category : #all }
Process >> suspendedContext [
	^ suspendedContext
]

{ #category : #all }
Process >> terminate [
	"Stop this process forever."

	Processor activeProcess == self
		ifTrue: [ thisContext removeSelf suspend ]
		ifFalse: [ myList
				ifNotNil: [ myList remove: self ifAbsent: [  ].
					myList := nil ].
			suspendedContext := nil ]
]

{ #category : #all }
Process >> isSuspended [
	^ suspendedContext isNotNil and: [ myList isNil ]
]

{ #category : #all }
Process >> idle [
	<primitive: 230>
]

{ #category : #all }
Process >> beIdleProcess [
	"Mark the receiver as THE idle Process (internal for CodeParadise).
	If another Process was already marked, it will no longer be recognized as the idle Process.
	A single (lowest priority) idle Process is required to recognize that no other Process
	is able to execute. In contrast with default behavior, the CodeParadise VM will then
	stop the interpretation loop. If events arrive, they will restart the interpretation loop."

	<primitive: 'primitiveProcessBeIdleProcess' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
Process >> allowAwaitPromise [

	"Answer whether the receiver allows awaiting (internal for CodeParadise)"

	<primitive: 'primitiveProcessAllowAwaitPromise' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
Process >> isSyncProcess [

	"Answer a Boolean whether the receiver is a synchronous Process.
	(Smalltalk) Blocks being used as (JavaScript) Functions are executed in a
	synchronous Process (prevent synchronous JavaScript Function to become
	async because of Process switching).
	Also CpEvent and CpTransition (for use with Browser DOM) are running in a
	synchronous Process."

	<primitive: 'primitiveProcessIsSyncProcess' module: 'CpSystemPlugin'>
	self primitiveFailed
]

{ #category : #all }
Process >> handleError: anError [
	"Log the unhandled error"
	self errorCr: 'Unhandled Error: ', anError printString.
	self errorCr: anError signalerContext printString.

	"Announce the exception"
	CpExceptionAnnouncer announceException: anError.

	"Terminate Process if part of await"
	self allowAwaitPromise
		ifTrue: [
			self traceCr: 'Terminating Process'.
			self terminate ]
]
