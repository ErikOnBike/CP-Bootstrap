Class {
	#name : #Announcer,
	#superclass : #Object,
	#instVars : [
		'registry'
	],
	#category : #'Announcement-Core'
}

{ #category : #all }
Announcer >> initialize [
	super initialize.

	registry := SubscriptionRegistry new
]

{ #category : #all }
Announcer >> announce: anAnnouncement [

	| announcement |
	announcement := anAnnouncement asAnnouncement.	
	registry deliver: announcement.
	^ announcement
]

{ #category : #all }
Announcer >> when: anAnnouncementClass do: aValuable [

	"Declare that when anAnnouncementClass is raised, aValuable is executed.
	Answer the AnnouncementSubscription created for this. This subsription
	should be used when removing intereset using #removeSubscription:"
	
	^ registry add: (
		AnnouncementSubscription new 
			announcementClass: anAnnouncementClass;
			action: aValuable ;
			yourself)
]

{ #category : #all }
Announcer >> removeSubscription: anAnnouncementSubscription [
	registry remove: anAnnouncementSubscription
]
