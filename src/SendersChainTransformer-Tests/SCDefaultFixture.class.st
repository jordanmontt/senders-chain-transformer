Class {
	#name : 'SCDefaultFixture',
	#superclass : 'Object',
	#instVars : [
		'senders',
		'initialCaller'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
}

{ #category : 'accessing' }
SCDefaultFixture >> initialCaller [

	^ initialCaller
]

{ #category : 'accessing' }
SCDefaultFixture >> initialCaller: anObject [

	initialCaller := anObject
]

{ #category : 'initialization' }
SCDefaultFixture >> initialize [

	super initialize.
	initialCaller := MethodWithOffset method: SCMockClass >> #foo offset: 45.
	senders := {
		           (MethodWithOffset method: Association class >> #key:value: offset: 42).
		           (MethodWithOffset method: Dictionary >> #at:put: offset: 82).
		           (MethodWithOffset method: SCAnotherMockClass >> #bar offset: 47) }
]

{ #category : 'accessing' }
SCDefaultFixture >> senders [

	^ senders
]

{ #category : 'accessing' }
SCDefaultFixture >> senders: anObject [

	senders := anObject
]
