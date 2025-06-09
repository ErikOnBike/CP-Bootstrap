Class {
	#name : #Boolean,
	#superclass : #Object,
	#category : #'Kernel-Objects'
}

{ #category : #all }
Boolean class >> new [
	"There is a single unique instance of each boolean."

	self cannotInstantiate
]

{ #category : #all }
Boolean >> shallowCopy [
	"There is the only one instance of me, so answer myself."

	^ self
]
