Class {
	#name : 'AllocationGraphFixture',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> entryPoint [

	"prim1 -> Behavior >> #basicNew
	prim2 -> Array >> #new: 2
	prim3 -> Behavior >> #basicNewTenured"
	self m6.
	self m7
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m1 [

	Behavior basicNew.
	Array new: 0
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m2 [

	Behavior basicNew
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m3 [

	Behavior basicNewTenured
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m4 [

	Behavior basicNewTenured
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m5 [

	Behavior basicNewTenured
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m6 [

	self m2.
	self m1.
	self m3
]

{ #category : 'as yet unclassified' }
AllocationGraphFixture class >> m7 [

	self m4.
	self m5
]
