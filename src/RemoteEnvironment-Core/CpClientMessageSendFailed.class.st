Class {
	#name : #CpClientMessageSendFailed,
	#superclass : #CpClientError,
	#instVars : [
		'messageSend'
	],
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpClientMessageSendFailed class >> messageSend: aMessageSend [

	^ self new
		messageSend: aMessageSend ;
		yourself
]

{ #category : #all }
CpClientMessageSendFailed class >> messageSend: aMessageSend description: aString [

	^ self new
		messageSend: aMessageSend ;
		description: aString ;
		yourself
]

{ #category : #all }
CpClientMessageSendFailed >> messageSend [

	^ messageSend
]

{ #category : #all }
CpClientMessageSendFailed >> messageSend: aMessageSend [

	messageSend := aMessageSend
]
