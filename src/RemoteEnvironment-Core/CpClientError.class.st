Class {
	#name : #CpClientError,
	#superclass : #Announcement,
	#instVars : [
		'description'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpClientError class >> description: aString [

	^ self new
		description: aString ;
		yourself
]

{ #category : #all }
CpClientError >> description [

	^ description
]

{ #category : #all }
CpClientError >> description: aString [

	description := aString
]
