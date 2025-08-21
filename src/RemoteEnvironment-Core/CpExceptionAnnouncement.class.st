Class {
	#name : #CpExceptionAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'exception',
		'announcerContext'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpExceptionAnnouncement class >> exception: anException [

	^ self exception: anException announcerContext: nil
]

{ #category : #all }
CpExceptionAnnouncement class >> exception: anException announcerContext: aContext [

	^ self basicNew
		initializeWithException: anException announcerContext: aContext ;
		yourself
]

{ #category : #all }
CpExceptionAnnouncement >> announcerContext [

	^ announcerContext
]

{ #category : #all }
CpExceptionAnnouncement >> exception [

	^ exception
]

{ #category : #all }
CpExceptionAnnouncement >> initializeWithException: anException announcerContext: aContext [

	self initialize.

	exception := anException.
	announcerContext := aContext
]
