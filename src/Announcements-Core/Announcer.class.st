Class {
	#name : #Announcer,
	#superclass : #Object,
	#instVars : [
		'registry'
	],
	#category : #'Announcements-Core'
}

{ #category : #all }
Announcer >> initialize [
	super initialize.

	registry := SubscriptionRegistry new
]

{ #category : #all }
Announcer >> release [
	registry ifNotNil: [
		registry release.
		registry := nil ].

	super release
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
Announcer >> when: anAnnouncementClass do: aBlock [
	self warnCr: 'Use of any Announcer''s #when:do: is deprecated, please use #when:do:for:'.

	^ self when: anAnnouncementClass do: aBlock for: aBlock receiver
]

{ #category : #all }
Announcer >> when: anAnnouncementClass do: aBlock for: anObject [

	"Subscribe anObject to announcements of anAnnouncementClass class. 
	 When announced, aBlock is evaluated."
	
	^ registry add: (
		AnnouncementSubscription new 
			announcer: self ;
			announcementClass: anAnnouncementClass ;
			valuable: aBlock ;
			subscriber: anObject ;
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
		for: anObject
]

{ #category : #all }
Announcer >> removeSubscription: anAnnouncementSubscription [
	^ registry remove: anAnnouncementSubscription
]

{ #category : #all }
Announcer >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	registry removeSubscriber: anObject
]
