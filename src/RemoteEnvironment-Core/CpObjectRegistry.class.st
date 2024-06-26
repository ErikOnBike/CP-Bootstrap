Class {
	#name : #CpObjectRegistry,
	#superclass : #Object,
	#instVars : [
		'objects',
		'objectsMutex'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpObjectRegistry >> idOfObject: anObject ifAbsent: aBlock [

	"Answer the identifier of the specified Object.
	If such an Object does not exist answer the result of evaluating the given Block."

	objectsMutex critical: [
		^ objects
			at: anObject
			ifAbsent: [ aBlock value ] ]
]

{ #category : #all }
CpObjectRegistry >> idOfObject: anObject [

	"Answer the identifier of the specified Object.
	An error will be raised if the Object is not registered."

	^ self
		idOfObject: anObject
		ifAbsent: [ Error signal: 'Object not registered: ', anObject printString ]
]

{ #category : #all }
CpObjectRegistry >> initialize [

	super initialize.

	objects := IdentityDictionary new.
	objectsMutex := Mutex new
]

{ #category : #all }
CpObjectRegistry >> objectWithId: identifier [

	"Answer the Object which is registered under the specified identifier.
	An error will be raised if such an Object does not exist."

	objectsMutex critical: [
		^ objects
			keyAtIdentityValue: identifier
			ifAbsent: [
				self errorCr: 'No object registered with identifier: ', identifier printString.

				"Answer nil"
				nil ] ]
]

{ #category : #all }
CpObjectRegistry >> registerObject: anObject withId: identifier [

	"Register the specified Object using the identifier supplied. Answer the registered Object."

	objectsMutex critical: [ objects at: anObject put: identifier ].

	^ anObject
]

{ #category : #all }
CpObjectRegistry >> release [

	"Release the receiver's instance variables"

	objects := nil.
	objectsMutex := nil.

	super release
]

{ #category : #all }
CpObjectRegistry >> unregisterObject: anObject [

	"Unregister the specified Object. Answer the unregistered Object.
	An error is raised if the Object is not registered."

	^ self
		unregisterObject: anObject
		ifAbsent: [ Error signal: 'Unregistering an Object which is not registered: ', anObject printString ]
]

{ #category : #all }
CpObjectRegistry >> unregisterObject: anObject ifAbsent: aBlock [

	"Unregister the specified Object. Answer the unregistered Object"

	objectsMutex critical: [ objects removeKey: anObject ifAbsent: aBlock ].

	^ anObject
]

{ #category : #all }
CpObjectRegistry >> unregisterObjectWithId: identifier [

	"Unregister the Object which is identified by the specified identifier. Answer the Object.
	An error will be raised if such an Object does not exist."

	objectsMutex critical: [

		| object |

		object := objects
			keyAtIdentityValue: identifier
			ifAbsent: [ Error signal: 'Unregistering an Object with unknown identifier: ', identifier printString ].

		^ self unregisterObject: object ]
]
