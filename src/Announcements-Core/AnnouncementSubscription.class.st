Class {
	#name : #AnnouncementSubscription,
	#superclass : #Object,
	#instVars : [
		'announcementClass',
		'action'
	],
	#category : #'Announcement-Core'
}

{ #category : #all }
AnnouncementSubscription >> action [
	^ action
]

{ #category : #all }
AnnouncementSubscription >> action: anObject [
	action := anObject
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
	^ self action cull: anAnnouncement
]

{ #category : #all }
AnnouncementSubscription >> handlesAnnouncement: anAnnouncement [

	^ self announcementClass handlesAnnouncement: anAnnouncement
]
