Class {
	#name : #Metaclass,
	#superclass : #Behavior,
	#instVars : [
		'soleInstance'
	],
	#category : #'Kernel-Classes'
}

{ #category : #all }
Metaclass >> initMethodDict: newMethodDict [
	"Initialize myself with the given method dictionary. Create but do not initialize my soleInstance."

	superclass := Class.
	methodDict := newMethodDict.
	format := Class format.	"all metaclasses have the same format as Class"
	soleInstance := self basicNew
]

{ #category : #all }
Metaclass >> isMeta [
	^ true
]

{ #category : #all }
Metaclass >> name [
	"Answer my name, either 'Metaclass' or the name of my class followed by ' class'."

	soleInstance
		ifNil: [ ^ 'Metaclass' ]
		ifNotNil: [ ^ soleInstance name , ' class' ]
]

{ #category : #all }
Metaclass >> new [
	"Each metaclass should have exactly one instance."

	self cannotInstantiate
]

{ #category : #all }
Metaclass >> soleInstance: aClass [
	soleInstance := aClass
]

{ #category : #all }
Metaclass >> theNonMetaClass [
	"Answer my only instance."

	^ soleInstance
]
