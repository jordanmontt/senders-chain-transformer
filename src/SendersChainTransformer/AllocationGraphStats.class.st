Class {
	#name : 'AllocationGraphStats',
	#superclass : 'Object',
	#instVars : [
		'lifetimes'
	],
	#category : 'SendersChainTransformer',
	#package : 'SendersChainTransformer'
}

{ #category : 'initialization' }
AllocationGraphStats >> initialize [

	super initialize.
	lifetimes := OrderedCollection new
]

{ #category : 'printing' }
AllocationGraphStats >> printOn: aStream [

	aStream
		nextPutAll: 'weight ';
		print: lifetimes size
]

{ #category : 'as yet unclassified' }
AllocationGraphStats >> updateFromSample: aSample [

	lifetimes add: aSample lifetime
]
