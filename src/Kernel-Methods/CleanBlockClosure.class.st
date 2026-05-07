Class {
	#name : #CleanBlockClosure,
	#superclass : #BlockClosure,
	#type : #variable,
	#instVars : [
		'literal'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
CleanBlockClosure class >> compiledBlock: compiledBlock [
	^ self new
		compiledBlock: compiledBlock ;
		numArgs: compiledBlock numArgs ;
		yourself
]

{ #category : #all }
CleanBlockClosure >> literal [
	"The variable and accessor should be in the subclass ConstantBlockClosure.
	It seems that the VM expects closures to have 4 ivars
	We should check if we can fix that."
	^ literal
]

{ #category : #all }
CleanBlockClosure >> receiver [
	^ nil
]
