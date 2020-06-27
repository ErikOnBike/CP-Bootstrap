Class {
	#name : #Announcement,
	#superclass : #Object,
	#category : #'Announcements-Core'
}

{ #category : #all }
Announcement class >> , anAnnouncementClass [
	^ AnnouncementSet with: self with: anAnnouncementClass
]

{ #category : #all }
Announcement class >> - anotherAnnouncement [
	"Create an announcement set containing the receiver 
	and anotherAnnouncement as exclusion."

	^ AnnouncementSetWithExclusions new
		add: self;
		addExclusion: anotherAnnouncement;
		yourself
]

{ #category : #all }
Announcement class >> asAnnouncement [
	^ self new
]

{ #category : #all }
Announcement class >> handlesAnnouncement: anAnnouncement [
	"The receiver acts as a filter to determine whether subscribers who used the receiver as signaling tag (event identifier class or symbol) should receive incoming announcement. In particular, registering to a superclass will receive the announcements from all subclasses."


	^ anAnnouncement class == self or: [ anAnnouncement class inheritsFrom: self ]
]

{ #category : #all }
Announcement >> cpEncodeWith: anEncoder [

	anEncoder encodeAnnouncement: self
]

{ #category : #all }
Announcement >> asAnnouncement [
	^ self
]

{ #category : #all }
Announcement >> prepareForDelivery [
	"This method will be executed once before subscriptions delivery.
	If nobody subscribed on me this method will not be called.
	It allows to put some heavy initialization logic here. It will be executed only 
	if there is interest on me"
]
