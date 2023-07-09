Class {
	#name : #System,
	#superclass : #Object,
	#classVars : [
		'SpecialObjectsArray'
	],
	#category : #'Kernel-System'
}

{ #category : #all }
System class >> getVMParameters [
	"Answer an Array containing the current values of the VM's internal parameter and statistics registers. The same primitive can be called with one integer argument to read a specific parameter and with two parameters to set a writable parameter, although these variations may not be implemented. Optional."

	"VM parameters are numbered as follows:
		1	end of old-space (0-based, read-only)
		2	end of young-space (read-only)
		3	end of memory (read-only)
		4	allocationCount (read-only)
		5	allocations between GCs (read-write)
		6	survivor count tenuring threshold (read-write)
		7	full GCs since startup (read-only)
		8	total milliseconds in full GCs since startup (read-only)
		9	incremental GCs since startup (read-only)
		10	total milliseconds in incremental GCs since startup (read-only)
		11	tenures of surving objects since startup (read-only)
		12-20 specific to the translating VM (obsolete)
		21   root table size (read-only)
		22   root table overflows since startup (read-only)"

	<primitive: 254>
	self primitiveFailed
]

{ #category : #all }
System class >> garbageCollect [
	"Primitive. Reclaims all garbage and answers the number of bytes of available space."

	<primitive: 130>
	self primitiveFailed
]

{ #category : #all }
System class >> incrementalGarbageCollect [
	"Primitive. Reclaims recently created garbage fairly quickly and answers the number of bytes of available space."

	<primitive: 131>
]

{ #category : #all }
System class >> exitToDebugger [
	"Tell the VM that we've encountered an unhandled error or halt."

	<primitive: 114>
]

{ #category : #all }
System class >> quit [
	"Exit from the system."

	<primitive: 113>
]

{ #category : #all }
System class >> snapshotAndQuit [
	| snapshotResult isImageStarting | 
	snapshotResult := System snapshotPrimitive.	"<--  frozen here on image file"
	isImageStarting := (snapshotResult == true).
	isImageStarting ifFalse: [ System quit ]
]

{ #category : #all }
System class >> snapshotPrimitive [
	"Primitive. Write the current state of the object memory on a file in the
	same format as the Smalltalk-80 release. The file can later be resumed,
	returning you to this exact state. Return normally after writing the file.
	Essential. See Object documentation whatIsAPrimitive."

	"I will return 
		true if the image is starting or
		false if the image is just resuming"

	<primitive: 97>
	^nil "indicates error writing image file"
]

{ #category : #all }
System class >> primitiveGetSpecialObjectsArray [
	"Answer the virtual machine's special objects array."

	<primitive: 129>
	self primitiveFailed
]

{ #category : #all }
System class >> specialObjectsArray [
	^ SpecialObjectsArray
]

{ #category : #all }
System class >> specialObjectsArray: anArray [
	SpecialObjectsArray := anArray
]

{ #category : #all }
System class >> registerExternalObject: anObject [

	| externalObjects index |
	externalObjects := SpecialObjectsArray at: 39.

	"Iterate over external objects finding first empty slot"
	index := 1.
	[ (index <= externalObjects size) and: [
		| obj |
		obj := externalObjects at: index.

		"Fake slot is empty if it is the same object as being registered"
		obj = anObject
			ifTrue: [ obj := nil ].
		obj notNil ] ] whileTrue: [
			index := index + 1 ].

	"If no slots are found, stop"
	(index <= externalObjects size)
		ifFalse: [ ^nil ].

	externalObjects at: index put: anObject.
	^ index
]

{ #category : #all }
System class >> unregisterExternalObject: anObject [

	| externalObjects |

	externalObjects := SpecialObjectsArray at: 39.
	1 to: externalObjects size do: [ :eachIndex |
		(externalObjects at: eachIndex) = anObject
			ifTrue: [ externalObjects at: eachIndex put: nil ] ]
]

{ #category : #all }
System class >> allObjectsDo: aBlock [
	"Evaluate the argument, aBlock, for each object in the system excluding SmallIntegers."

	| object |
	object := self someObject.
	[ 0 == object ]
		whileFalse: [ aBlock value: object.
			object := object nextObject ]
]

{ #category : #all }
System class >> start [

	self crTrace: 'CodeParadise tiny image (build v8-20230709)'.
	self crTrace: 'Smalltalk client-environment fired up!'.

	self crTrace: 'Fixing the world'.
	Smalltalk at: #GlobalVariable put: Association.
	Smalltalk at: #ClassVariable put: Association.
	Smalltalk at: #BlockClosure put: Block.

	self crTrace: 'Creating Symbol table'.
	Symbol initSymbolTable.

	"Create idle process to have at least one process being in a woken state"
	self crTrace: 'Starting idle process'.
	(Process for: [ [ Processor activeProcess idle ] repeat ] priority: 1) resume.

	self crTrace: 'Creating client environment and starting communication'.
	CpClientEnvironment current startCommunication.

	"Suspend main process until image exits"
	[
		self crTrace: 'Main process going to suspend'.
		Processor activeProcess suspend ] repeat. "Do nothing if we get active again"
]
