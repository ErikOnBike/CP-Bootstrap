Class {
	#name : #CpClientStarted,
	#superclass : #Announcement,
	#instVars : [
		'app'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpClientStarted class >> app: identifier [

	^ self new
		app: identifier ;
		yourself
]

{ #category : #all }
CpClientStarted >> app [

	^ app
]

{ #category : #all }
CpClientStarted >> app: identifier [

	app := identifier
]
