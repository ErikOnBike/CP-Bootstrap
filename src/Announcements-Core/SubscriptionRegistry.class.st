Class {
	#name : #SubscriptionRegistry,
	#superclass : #Object,
	#instVars : [
		'subscriptions',
		'subscriptionsMutex'
	],
	#category : #'Announcements-Core'
}

{ #category : #all }
SubscriptionRegistry >> initialize [

	super initialize.

	subscriptionsMutex := Mutex new.
	self reset
]

{ #category : #all }
SubscriptionRegistry >> release [

	subscriptions ifNotNil: [
		subscriptions do: [ :each | each release ].
		subscriptions removeAll.
		subscriptions := nil ].
	subscriptionsMutex ifNotNil: [
		subscriptionsMutex release.
		subscriptionsMutex := nil ].

	super release
]

{ #category : #all }
SubscriptionRegistry >> reset [
	"Use an OrderedCollection since the order in which elements are added IS important
	when using it to register DOM events".
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
		interestedSubscriptions := subscriptions copy ].
	interestedSubscriptions isEmpty ifTrue: [ ^ self ].

	"Prevent duplicate validation of all announcements: if any announcement matches, assume delivery"
	(interestedSubscriptions anySatisfy: [ :each | each handlesAnnouncement: anAnnouncement ])
		ifFalse: [ ^ self ].
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

{ #category : #all }
SubscriptionRegistry >> subscriptionsOf: aSubscriber do: aBlock [
	| copy |

	subscriptionsMutex critical: [ copy := subscriptions copy ].

	copy do:
		[:subscription |
			subscription subscriber == aSubscriber
				ifTrue: [ aBlock value: subscription ]	]
]
