Class {
	#name : 'SCTransformationsForTwoAllocationSitesInSameMethodMock',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Fixtures',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Fixtures'
}

{ #category : 'adding' }
SCTransformationsForTwoAllocationSitesInSameMethodMock >> addOccupant: anObject [

	(self theOccupants at: anObject class name ifAbsentPut: [ OrderedCollection new ]) add: anObject
]

{ #category : 'adding' }
SCTransformationsForTwoAllocationSitesInSameMethodMock >> theOccupants [

	^ {  }
]
