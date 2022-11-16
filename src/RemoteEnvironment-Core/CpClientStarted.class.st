Class {
	#name : #CpClientStarted,
	#superclass : #Announcement,
	#instVars : [
		'variables'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpClientStarted class >> variables: aDictionary [

	^ self new
		variables: aDictionary ;
		yourself
]

{ #category : #all }
CpClientStarted >> variables: aDictionary [

	variables := aDictionary
]
