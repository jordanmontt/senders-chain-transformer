Class {
	#name : 'SCMockWithBlockclosureClass',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Mocking',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Mocking'
}

{ #category : 'as yet unclassified' }
SCMockWithBlockclosureClass >> theMethod [

	| tmp1 |
	1 = tmp1 something: [ OrderedCollection new ].
	tmp1 anotherThing: [ Dictionary new ].
	^ self
]
