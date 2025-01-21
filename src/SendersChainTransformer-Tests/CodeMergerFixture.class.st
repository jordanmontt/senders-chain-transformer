Class {
	#name : 'CodeMergerFixture',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Fixtures',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Fixtures'
}

{ #category : 'adding' }
CodeMergerFixture >> addOccupant: anObject [

	(self theOccupants at: anObject class name ifAbsentPut: [ OrderedCollection new ]) add: anObject
]

{ #category : 'adding' }
CodeMergerFixture >> at: key ifAbsentPut: aBlock [

	^ self at: key ifAbsent: [ self at: key put: aBlock value ]
]
