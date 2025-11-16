Class {
	#name : #Mutex,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'owner'
	],
	#category : #'Kernel-Processes'
}

{ #category : #all }
Mutex >> critical: aBlock [
	"Evaluate aBlock protected by the receiver."
	| activeProcess |

	activeProcess := Processor activeProcess.
	activeProcess == owner ifTrue:[ ^ aBlock value ].
	^ semaphore critical: [
		owner := activeProcess.
		aBlock ensure:[ owner := nil ] ]
]

{ #category : #all }
Mutex >> initialize [
	super initialize.
	semaphore := Semaphore forMutualExclusion.
]

{ #category : #all }
Mutex >> release [
	semaphore ifNotNil: [
		semaphore release.
		semaphore := nil ].

	"Do not release owner (not our responsibility)"
	owner := nil.

	super release
]
