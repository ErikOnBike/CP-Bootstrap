Class {
	#name : #Class,
	#superclass : #Behavior,
	#instVars : [
		'instanceVariableNames',
		'classPool',
		'subclasses',
		'name',
		'filler1',
		'filler2',
		'filler3',
		'filler4'
	],
	#category : #'Kernel-Classes'
}

{ #category : #all }
Class >> instanceSide [
	"Answer the class's instance (ie myself)"
	^ self
]

{ #category : #all }
Class >> classSide [
	"Answer the class's class"
	^ self class
]

{ #category : #all }
Class >> classPool [
	"Answer the dictionary of class variables that I share with my sole instance, or nil if I have none."

	^ classPool
]

{ #category : #all }
Class >> classPool: aDictionary [
	"Set my (private) class pool dictionary"

	classPool := aDictionary
]

{ #category : #all }
Class >> classVarNames [
	^ classPool keys
]

{ #category : #all }
Class >> addClassVarNamed: aSymbol [
	"Add an entry to the receiver's class pool for the specified name"
	classPool at: aSymbol put: nil
]

{ #category : #all }
Class >> instVarNames [
	"Answer an Array of the receiver's instance variable names."

	^ instanceVariableNames ifNil: [ #() ]
]

{ #category : #all }
Class >> allInstVarNames [
	"Answer an Array of the names of the receiver's instance variables. The 
	Array ordering is the order in which the variables are stored and 
	accessed by the interpreter."

	^ self superclass
		ifNotNil: [ :sup | sup allInstVarNames , self instVarNames ]
		ifNil: [ self instVarNames ]
]

{ #category : #all }
Class >> instVarNames: anArray [
	instanceVariableNames := anArray
]

{ #category : #all }
Class >> indexOfInstVarName: aSymbol [
	"Answer the index of the specified variable name (or 0 if name does not exist)"
	| delta |
	delta := 0.
	self classHierarchyDo: [ :each |
		(each instVarNames indexOf: aSymbol ifAbsent: [ nil ])
			ifNotNil: [ :index | ^ index + delta ].
		delta := delta + each instVarNames size ].
	^ 0
]

{ #category : #all }
Class >> classHierarchyDo: aBlock [
	"Evaluate the specified block for all classes in the receiver's
	hierarchy, starting at the Class farthest away from the receiver"

	self superclass
		ifNotNil: [ :sup | sup classHierarchyDo: aBlock. aBlock value: self ]
		ifNil: [ aBlock value: self ]
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
Class >> withAllSubclassesDo: aBlock [
	aBlock value: self.
	self allSubclassesDo: aBlock
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
Class >> removeSubclass: aSubclass [
	subclasses ifNil: [ ^ self ].
	subclasses withIndexDo: [ :each :index | each == aSubclass ifTrue: [
		| newSubclasses |
		newSubclasses := Array new: subclasses size - 1.
		index > 1 ifTrue: [
			newSubclasses
				replaceFrom: 1
				to: index - 1
				with: subclasses
				startingAt: 1 ].
		newSubclasses
			replaceFrom: index
			to: newSubclasses size
			with: subclasses
			startingAt: index + 1.
		subclasses = newSubclasses.
		^ self ] ]
]

{ #category : #all }
Class >> subclass: subclassName instanceVariableNames: instVarNames classVariableNames: classVarNames [
	^ self subclass: subclassName instanceVariableNames: instVarNames classVariableNames: classVarNames instanceVariableNames: #()
]

{ #category : #all }
Class >> subclass: subclassName instanceVariableNames: instVarNames classVariableNames: classVarNames classInstanceVariableNames: classInstVarNames [
	^ ClassBuilder new
		superclass: self ;
		name: subclassName ;
		instVarNames: instVarNames ;
		classVariableNames: classVarNames ;
		classInstVarNames: classInstVarNames ;
		build
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
Class >> classVariableNamed: aSymbol [
	^ classPool associationAt: aSymbol ifAbsent: [ self superclass classVariableNamed: aSymbol ]
]

{ #category : #all }
Class >> installMethod: aCompiledMethod [
	self installInstanceMethod: aCompiledMethod
]

{ #category : #all }
Class >> removeMethod: aCompiledMethod [
	self removeInstanceMethod: aCompiledMethod
]

{ #category : #all }
Class >> cpEncodeWith: anEncoder [
	anEncoder encodeSymbol: self name
]
