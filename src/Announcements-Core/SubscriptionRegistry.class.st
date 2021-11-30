Class {
	#name : #SubscriptionRegistry,
	#superclass : #Object,
	#instVars : [
		'subscriptions',
		'subscriptionsMutex'
	],
	#category : #'Announcement-Core'
}

{ #category : #all }
SubscriptionRegistry >> initialize [

	super initialize.

	subscriptionsMutex := Mutex new.
	self reset
]

{ #category : #all }
SubscriptionRegistry >> reset [
	subscriptions := OrderedCollection new
]

{ #category : #all }
SubscriptionRegistry >> subscriptions [
	^ subscriptions
]

{ #category : #all }
SubscriptionRegistry >> add: aSubscription [
	^ subscriptionsMutex critical: [ self subscriptions add: aSubscription ]
]

{ #category : #all }
SubscriptionRegistry >> deliver: anAnnouncement [
	|  interestedSubscriptions |
	"using a copy, so subscribers can unsubscribe from announcer "
	
	subscriptions isEmpty ifTrue: [ ^ self ].
	subscriptionsMutex critical: [ 
		interestedSubscriptions := self subscriptionsHandling: anAnnouncement ].
	interestedSubscriptions isEmpty ifTrue: [ ^ self ].
	
	anAnnouncement prepareForDelivery.
	self deliver: anAnnouncement to: interestedSubscriptions
]

{ #category : #all }
SubscriptionRegistry >> deliver: anAnnouncement to: subs [
	^ self deliver: anAnnouncement to: subs startingAt: 1
]

{ #category : #all }
SubscriptionRegistry >> deliver: anAnnouncement to: subs startingAt: startIndex [
	
	startIndex to: subs size do: [ :index| | subscription |
		subscription := subs at: index.
		[ subscription deliver: anAnnouncement ] 
			"Ensure delivery to remaining announcements"
			ifCurtailed: [
				self deliver: anAnnouncement to: subs startingAt: index + 1 ] ]
]

{ #category : #all }
SubscriptionRegistry >> remove: subscription [
	^ subscriptionsMutex critical: [
		subscriptions remove: subscription ifAbsent: nil ]
]

{ #category : #all }
SubscriptionRegistry >> removeSubscriber: subscriber [
	^ subscriptionsMutex critical: [
		subscriptions removeAllSuchThat: [ :subscription | subscription subscriber == subscriber ] ]
]

{ #category : #all }
SubscriptionRegistry >> subscriptionsHandling: anAnnouncement [
	^ subscriptions select: [ :each | each handlesAnnouncement: anAnnouncement ]
]
