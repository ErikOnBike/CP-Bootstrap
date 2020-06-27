Class {
	#name : #AnnouncementSet,
	#superclass : #Set,
	#category : #'Announcements-Core'
}

{ #category : #all }
AnnouncementSet >> , anAnnouncementClass [
	self add: anAnnouncementClass
]

{ #category : #all }
AnnouncementSet >> - anotherAnnouncement [
	"Create an announcement set containnig the receiver
	and anotherAnnouncement as an exclusion."

	^ AnnouncementSetWithExclusions new
		add: self;
		addExclusion: anotherAnnouncement;
		yourself
]

{ #category : #all }
AnnouncementSet >> handlesAnnouncement: anAnnouncement [
	"If any of the set handles the announcements, subscribers should receive it."
	^ self anySatisfy: [ :each | each handlesAnnouncement: anAnnouncement ]
]
