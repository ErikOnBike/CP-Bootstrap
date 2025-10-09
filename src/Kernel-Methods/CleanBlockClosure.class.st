Class {
	#name : #CleanBlockClosure,
	#superclass : #BlockClosure,
	#type : #variable,
	#category : #'Kernel-Methods'
}

{ #category : #all }
CleanBlockClosure class >> numArgs: anInteger [
	^ self new
		numArgs: anInteger ;
		yourself
]

{ #category : #all }
CleanBlockClosure >> receiver [
	^ nil
]
