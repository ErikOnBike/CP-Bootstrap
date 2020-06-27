Class {
	#name : #Class,
	#superclass : #Behavior,
	#instVars : [
		'name',
		'instVarNames',
		'classVariables',
		'subclasses'
	],
	#category : #'Kernel-Classes'
}

{ #category : #all }
Class >> classSide [
	^ self class
]

{ #category : #all }
Class >> classVariables [
	"Answer the dictionary of class variables that I share with my sole instance, or nil if I have none."

	^ classVariables
]

{ #category : #all }
Class >> classVarNames [
	^ classVariables ifNotNil: [ :classVars | classVars keys ]
]

{ #category : #all }
Class >> classVariables: aDictionary [
	"Answer the dictionary of class variables that I share with my sole instance, or nil if I have none."

	^ classVariables := aDictionary
]

{ #category : #all }
Class >> immediateSubclass: subclassName instanceVariableNames: someInstVarNames classVariableNames: classVarNames [
	^ (self
		newClassBuilderForSubclass: subclassName
		instanceVariableNames: someInstVarNames
		classVariableNames: classVarNames)
		beImmediate;
		build
]

{ #category : #all }
Class >> instVarNames [
	"Answer an Array of the receiver's instance variable names."

	instVarNames ifNil: [ ^ #() ].
	^ instVarNames
]

{ #category : #all }
Class >> instVarNames: anArray [
	instVarNames := anArray
]

{ #category : #all }
Class >> isClass [
	^ true
]

{ #category : #all }
Class >> isMeta [
	^ false
]

{ #category : #all }
Class >> allSubclassesDo: aBlock [
	self subclassesDo: [ :each |
		aBlock value: each.
		each subclassesDo: aBlock ]
]

{ #category : #all }
Class >> subclassesDo: aBlock [
	subclasses
		ifNotNil: [ subclasses do: aBlock ]
]

{ #category : #all }
Class >> allSubclasses [
	"Answer a Set of the receiver's and the receiver's descendent's subclasses. "

	| scan scanTop |
	scan := OrderedCollection withAll: self subclasses.
	scanTop := 1.
	[ scanTop > scan size ]
		whileFalse: [
			scan addAll: (scan at: scanTop) subclasses.
			scanTop := scanTop + 1 ].
	^ scan asSet
]

{ #category : #all }
Class >> subclasses [
	"Answer a Set containing the receiver's subclasses."

	^ subclasses
		ifNil: [#()]
		ifNotNil: [subclasses copy]
]

{ #category : #all }
Class >> addSubclass: aSubclass [
	aSubclass superclass ~~ self
		ifTrue: [ self error: aSubclass name, ' is not my subclass' ].
	subclasses ifNil: [
		subclasses := Array with: aSubclass.
		^ self ].

	subclasses do: [ :each | each == aSubclass ifTrue: [ ^ self ] ].	"Already my subclass"
	subclasses := subclasses copyWith: aSubclass
]

{ #category : #all }
Class >> name [
	^ name
]

{ #category : #all }
Class >> name: aSymbol [
	name := aSymbol
]

{ #category : #all }
Class >> newClassBuilderForSubclass: subclassName instanceVariableNames: instVarNames classVariableNames: classVarNames [
	^ ClassBuilder new
		superclass: self;
		name: subclassName;
		instVarNames: instVarNames;
		classVariableNames: classVarNames;
		yourself
]

{ #category : #all }
Class >> subclass: subclassName instanceVariableNames: someInstVarNames classVariableNames: classVarNames [
	^ (self
		newClassBuilderForSubclass: subclassName
		instanceVariableNames: someInstVarNames
		classVariableNames: classVarNames)
		yourself;
		build
]

{ #category : #all }
Class >> postInstall [
	"Extension for client side initialization of classes when installed through CpBaseWebApplicationClient or its subclasses"
]

{ #category : #all }
Class >> theNonMetaClass [
	^ self
]

{ #category : #all }
Class >> variableByteSubclass: subclassName instanceVariableNames: someInstVarNames classVariableNames: classVarNames [
	^ (self
		newClassBuilderForSubclass: subclassName
		instanceVariableNames: someInstVarNames
		classVariableNames: classVarNames)
		beBytes;
		build
]

{ #category : #all }
Class >> variableSubclass: subclassName instanceVariableNames: someInstVarNames classVariableNames: classVarNames [
	^ (self
		newClassBuilderForSubclass: subclassName
		instanceVariableNames: someInstVarNames
		classVariableNames: classVarNames)
		beVariable;
		build
]

{ #category : #all }
Class >> variableWordSubclass: subclassName instanceVariableNames: someInstVarNames classVariableNames: classVarNames [
	^ (self
		newClassBuilderForSubclass: subclassName
		instanceVariableNames: someInstVarNames
		classVariableNames: classVarNames)
		beWords;
		build
]

{ #category : #all }
Class >> weakSubclass: subclassName instanceVariableNames: someInstVarNames classVariableNames: classVarNames [
	^ (self
		newClassBuilderForSubclass: subclassName
		instanceVariableNames: someInstVarNames
		classVariableNames: classVarNames)
		beWeak;
		build
]

{ #category : #all }
Class >> classVariableNamed: aSymbol [
	^ self classVariables associationAt: aSymbol ifAbsent: [ self superclass classVariableNamed: aSymbol ]
]

{ #category : #all }
Class >> cpEncodeWith: anEncoder [
	anEncoder encodeSymbol: self name
]
