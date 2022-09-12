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
Announcer >> subscriptions [

	^ registry
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
			valuable: aValuable ;
			yourself)
]

{ #category : #all }
Announcer >> when: anAnnouncementClass send: aSelector to: anObject [
	"Declare that when anAnnouncementClass is raised, anObject should receive the message aSelector.
    When the message expects one argument (eg #fooAnnouncement:) the announcement is passed as argument.
    When the message expects two arguments (eg #fooAnnouncement:announcer:) both the announcement and 
    the announcer are passed as argument"

	^ self
		when: anAnnouncementClass
		do: (MessageSend receiver: anObject selector: aSelector)
]

{ #category : #all }
Announcer >> removeSubscription: anAnnouncementSubscription [
	^ registry remove: anAnnouncementSubscription
]

{ #category : #all }
Announcer >> removeInterestIn: anAnnouncementClass for: anObject [

	"Remove interest in the specified AnnouncementClass for the specified subscriber"

	registry subscriptionsOf: anObject do: [ :each |
		each announcementClass == anAnnouncementClass
			ifTrue: [ self removeSubscription: each ] ]
]
