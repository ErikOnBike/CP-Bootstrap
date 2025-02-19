Class {
	#name : #UnhandledError,
	#superclass : #Exception,
	#instVars : [
		'exception'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
UnhandledError class >> signalForException: anError [

	^ self new
		exception: anError;
		signal
]

{ #category : #all }
UnhandledError >> defaultAction [
	Processor activeProcess handleError: exception
]

{ #category : #all }
UnhandledError >> exception [

	^ exception
]

{ #category : #all }
UnhandledError >> exception: anError [

	exception := anError
]

{ #category : #all }
UnhandledError >> isResumable [
	
	^ false
]
