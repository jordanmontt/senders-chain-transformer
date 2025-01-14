Class {
	#name : 'SCTwoAllocationSitesInSameMethodFixture',
	#superclass : 'Object',
	#instVars : [
		'initialCaller',
		'senders',
		'senders2',
		'initialCaller2'
	],
	#category : 'SendersChainTransformer-Tests-Fixtures',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Fixtures'
}

{ #category : 'accessing' }
SCTwoAllocationSitesInSameMethodFixture >> initialCaller [

	^ initialCaller
]

{ #category : 'accessing' }
SCTwoAllocationSitesInSameMethodFixture >> initialCaller2 [

	^ initialCaller2
]

{ #category : 'initialization' }
SCTwoAllocationSitesInSameMethodFixture >> initialize [

	super initialize.
	initialCaller := MethodWithOffset
		                 method: SCTransformationsForTwoAllocationSitesInSameMethodMock >> #addOccupant:
		                 offset: 81.
	senders := {
		           (MethodWithOffset method: Association class >> #key:value: offset: 42).
		           (MethodWithOffset method: Dictionary >> #at:put: offset: 82).
		           (MethodWithOffset method: (Dictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (MethodWithOffset method: Dictionary >> #at:ifAbsent: offset: 54).
		           (MethodWithOffset method: Dictionary >> #at:ifAbsentPut: offset: 48) }.


	initialCaller2 := MethodWithOffset
		                  method: (SCTransformationsForTwoAllocationSitesInSameMethodMock >> #addOccupant: literalsAt: 4)
		                  offset: 26.
	senders2 := {
		            (MethodWithOffset method: OrderedCollection class >> #new: offset: 50).
		            (MethodWithOffset method: OrderedCollection class >> #new offset: 35) }
]

{ #category : 'accessing' }
SCTwoAllocationSitesInSameMethodFixture >> senders [

	^ senders
]

{ #category : 'accessing' }
SCTwoAllocationSitesInSameMethodFixture >> senders2 [

	^ senders2
]
