Class {
	#name : 'SCMockWithBlockclosureClass',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Mocking',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Mocking'
}

{ #category : 'as yet unclassified' }
SCMockWithBlockclosureClass >> theMethod [

	| myVar |
	myVar anotherThing: [ Dictionary new ].
	1 = myVar something: [
		Object new. "Do not change this"
		SCMockWithBlockclosureClass new "this is the selector to change" ].
	^ self
]
