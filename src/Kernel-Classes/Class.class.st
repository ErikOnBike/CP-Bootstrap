Class {
	#name : #Class,
	#superclass : #Behavior,
	#instVars : [
		'instVarNames',
		'classVariables',
		'subclasses',
		'name'
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
		each allSubclassesDo: aBlock ]
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
Class >> nameWithoutPrefix [

	"Answer a String representing the receiver's name without any prefixes.

	Implementation: Prefixes are either 2 or 3 character Strings coming before a
	capitalized name. For prefixes with all uppercase characters the first lowercase
	character indicates where the name starts (just one character before it ;-).
	If no prefix can be found the full name is answered.
	"

	| firstLowercaseIndex secondUppercaseIndex |

	firstLowercaseIndex := name findFirst: [ :each | each isLowercase ].
	firstLowercaseIndex < 2
		ifTrue: [ ^ name asString ].

	secondUppercaseIndex := name findNext: [ :each | each isUppercase ] after: firstLowercaseIndex.
	secondUppercaseIndex = 0
		ifTrue: [ ^ name asString allButFirst: firstLowercaseIndex - 2 ].

	^ secondUppercaseIndex <= 4
		ifTrue: [ name asString allButFirst: secondUppercaseIndex - 1 ]
		ifFalse: [ name asString allButFirst: firstLowercaseIndex - 2 ]
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
	"Perform any necessary initialization after receiver is installed in the ClientEnvironment.
	In contrast with a class side #initialize, this method should be called from subclasses
	using [[[ super postInstall ]]].
	In case initialization is strictly for the class itself (and should not be re-executed for
	any subclasses), use #postInstallOnce"

	(self classSide includesSelector: #postInstallOnce)
		ifTrue: [ self postInstallOnce ]
]

{ #category : #all }
Class >> postInstallOnce [

	"Perform any necessary initialization after receiver is installed in the ClientEnvironment.
	In contrast with #postInstall, this method should NOT chain post install methods from the
	super class."
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

{ #category : #all }
Class >> beLoaded [

	"Empty method, but referring to this method directly (ie [[[ CpTransition beLoaded ]]])
	from a method to be installed in a ClientEnvironment will also install the receiver (class)
	in the ClientEnvironment"
]
