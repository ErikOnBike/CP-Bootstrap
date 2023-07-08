Class {
	#name : #CpExceptionAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'exception'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpExceptionAnnouncement class >> exception: anException [

	^ self basicNew
		initializeWithException: anException ;
		yourself
]

{ #category : #all }
CpExceptionAnnouncement >> initializeWithException: anException [

	self initialize.

	exception := anException
]

{ #category : #all }
CpExceptionAnnouncement >> exception [

	^ exception
]
