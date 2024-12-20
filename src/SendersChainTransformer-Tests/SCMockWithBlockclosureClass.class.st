Class {
	#name : 'SCMockWithBlockclosureClass',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
}

{ #category : 'as yet unclassified' }
SCMockWithBlockclosureClass >> theMethod [

	| tmp1 |
	1 = tmp1 something: [ OrderedCollection new ].
	^ self
]
