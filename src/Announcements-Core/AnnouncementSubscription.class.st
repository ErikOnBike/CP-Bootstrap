Class {
	#name : #AnnouncementSubscription,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'announcementClass',
		'action',
		'subscriber'
	],
	#category : #'Announcements-Core'
}

{ #category : #all }
AnnouncementSubscription >> announcer [
	^ announcer
]

{ #category : #all }
AnnouncementSubscription >> action [
	^ action
]

{ #category : #all }
AnnouncementSubscription >> subscriber [
	^ subscriber
]

{ #category : #all }
AnnouncementSubscription >> announcer: anAnnouncer [
	announcer := anAnnouncer
]

{ #category : #all }
AnnouncementSubscription >> action: anObject [
	action := anObject
]

{ #category : #all }
AnnouncementSubscription >> release [

	"No instance variable's content is created by the receiver, only nil them out.
	Do NOT release the instance variables, it is not our responsibility."
	announcer := nil.
	announcementClass := nil.
	action := nil.
	subscriber := nil.

	super release
]

{ #category : #all }
AnnouncementSubscription >> subscriber: anObject [
	subscriber := anObject
]

{ #category : #all }
AnnouncementSubscription >> unsubscribe [
	announcer removeSubscription: self
]

{ #category : #all }
AnnouncementSubscription >> valuable: aValuable [
	self action: aValuable
]

{ #category : #all }
AnnouncementSubscription >> announcementClass [
	^ announcementClass
]

{ #category : #all }
AnnouncementSubscription >> announcementClass: anAnnouncementClass [
	announcementClass := anAnnouncementClass
]

{ #category : #all }
AnnouncementSubscription >> deliver: anAnnouncement [
	(self handlesAnnouncement: anAnnouncement)
		ifTrue: [ self action cull: anAnnouncement ]
]

{ #category : #all }
AnnouncementSubscription >> handlesAnnouncement: anAnnouncement [

	^ self announcementClass handlesAnnouncement: anAnnouncement
]
