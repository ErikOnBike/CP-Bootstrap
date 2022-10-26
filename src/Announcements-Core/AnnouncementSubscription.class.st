Class {
	#name : #AnnouncementSubscription,
	#superclass : #Object,
	#instVars : [
		'announcementClass',
		'action',
		'subscriber'
	],
	#category : #'Announcements-Core'
}

{ #category : #all }
AnnouncementSubscription >> action [
	^ action
]

{ #category : #all }
AnnouncementSubscription >> subscriber [
	^ subscriber
]

{ #category : #all }
AnnouncementSubscription >> action: anObject [
	action := anObject
]

{ #category : #all }
AnnouncementSubscription >> subscriber: anObject [
	subscriber := anObject
]

{ #category : #all }
AnnouncementSubscription >> valuable: aValuable [
	self action: aValuable.
	self subscriber: aValuable receiver
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
