Class {
	#name : 'SCFullBlockClosureFixture',
	#superclass : 'Object',
	#instVars : [
		'senders',
		'initialCaller'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
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

	initialCaller := MethodWithOffset method: SCMockWithBlockclosureClass >> #theMethod offset: 26.
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
