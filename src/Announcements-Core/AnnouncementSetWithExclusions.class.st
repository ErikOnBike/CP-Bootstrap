Class {
	#name : #AnnouncementSetWithExclusions,
	#superclass : #AnnouncementSet,
	#instVars : [
		'exclusions'
	],
	#category : #'Announcements-Core'
}

{ #category : #all }
AnnouncementSetWithExclusions >> addExclusion: anAnnouncement [
	"Add anAnnouncement as an exclusion to me.
	I will explicitely not handle my exclusion announcements."
	
	^ exclusions add: anAnnouncement 
]

{ #category : #all }
AnnouncementSetWithExclusions >> handlesAnnouncement: anAnnouncement [
	"Return true when I will handle anAnnouncement.
	I extend my superclass behavior by explicitely 
	not handling the exclusions."

	^ (super handlesAnnouncement: anAnnouncement) 
			and: [ exclusions noneSatisfy: [ :each | each handlesAnnouncement: anAnnouncement ] ]
]

{ #category : #all }
AnnouncementSetWithExclusions >> initialize [

	super initialize.
	exclusions := OrderedCollection new
]

{ #category : #all }
AnnouncementSetWithExclusions >> initialize: aNumber [

	super initialize: aNumber.
	exclusions := OrderedCollection new
]
