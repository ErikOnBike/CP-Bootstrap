Class {
	#name : #Metaclass,
	#superclass : #Behavior,
	#instVars : [
		'instanceVariableNames',
		'thisClass',
		'filler1'
	],
	#category : #'Kernel-Classes'
}

{ #category : #all }
Metaclass >> isMeta [
	^ true
]

{ #category : #all }
Metaclass >> name [
	"Answer my name, either 'Metaclass' or the name of my class followed by ' class'."

	thisClass
		ifNil: [ ^ 'Metaclass' ]
		ifNotNil: [ ^ thisClass name , ' class' ]
]

{ #category : #all }
Metaclass >> new [
	"Each metaclass should have exactly one instance."

	thisClass class ~~ self
		ifTrue: [ ^ thisClass := self basicNew initialize ]
		ifFalse: [ self cannotInstantiate ]
]

{ #category : #all }
Metaclass >> instanceSide [
	"Answer the class's instance"
	^ thisClass
]

{ #category : #all }
Metaclass >> classSide [
	"Answer the class's class (ie myself)"
	^ self
]

{ #category : #all }
Metaclass >> instVarNames [
	^ instanceVariableNames
]

{ #category : #all }
Metaclass >> instVarNames: anArray [
	instanceVariableNames := anArray
]

{ #category : #all }
Metaclass >> installMethod: aCompiledMethod [
	self instanceSide installClassMethod: aCompiledMethod
]

{ #category : #all }
Metaclass >> removeMethod: aCompiledMethod [
	self instanceSide removeClassMethod: aCompiledMethod
]
