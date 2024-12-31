Class {
	#name : 'SCFullBlockClosureFixture',
	#superclass : 'Object',
	#instVars : [
		'senders',
		'initialCaller'
	],
	#category : 'SendersChainTransformer-Tests-Fixtures',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Fixtures'
}

{ #category : 'accessing' }
SCFullBlockClosureFixture >> initialCaller [

	^ initialCaller
]

{ #category : 'accessing' }
SCFullBlockClosureFixture >> initialCaller: anObject [

	initialCaller := anObject
]

{ #category : 'initialization' }
SCFullBlockClosureFixture >> initialize [

	super initialize.

	initialCaller := MethodWithOffset
		                 method: (SCMockWithBlockclosureClass >> #theMethod) literals third
										"the desired block closure"
		                 offset: 37.
	senders := {
		           (MethodWithOffset method: OrderedCollection class >> #new: offset: 50).
		           (MethodWithOffset method: OrderedCollection class >> #new offset: 35) }
]

{ #category : 'accessing' }
SCFullBlockClosureFixture >> senders [

	^ senders
]

{ #category : 'accessing' }
SCFullBlockClosureFixture >> senders: anObject [

	senders := anObject
]
