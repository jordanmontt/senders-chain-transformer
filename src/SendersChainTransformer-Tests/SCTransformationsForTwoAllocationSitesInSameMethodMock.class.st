Class {
	#name : 'SCTransformationsForTwoAllocationSitesInSameMethodMock',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Mocking',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Mocking'
}

{ #category : 'adding' }
SCTransformationsForTwoAllocationSitesInSameMethodMock >> addOccupant: anObject [

	(self theOccupants at: anObject class name ifAbsentPut: [ OrderedCollection new ]) add: anObject
]

{ #category : 'adding' }
SCTransformationsForTwoAllocationSitesInSameMethodMock >> theOccupants [

	^ {  }
]
