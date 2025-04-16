Class {
	#name : 'AllocationGraphStats',
	#superclass : 'Object',
	#instVars : [
		'allocatedSamples'
	],
	#category : 'SendersChainTransformer-Allocation-Graph',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Graph'
}

{ #category : 'accessing' }
AllocationGraphStats >> allocatedSamples [
	^ allocatedSamples
]

{ #category : 'initialization' }
AllocationGraphStats >> initialize [

	super initialize.
	allocatedSamples := Set new
]

{ #category : 'printing' }
AllocationGraphStats >> printOn: aStream [

	aStream
		nextPutAll: 'weight ';
		print: allocatedSamples size
]

{ #category : 'as yet unclassified' }
AllocationGraphStats >> updateFromSample: aSample [
	"| stats |
	stats := allocNodeStatistics at: aSample allocatedObjectClass ifAbsentPut: AllocationGraphStats new.
	stats updateFromSample: aSample."
	allocatedSamples add: aSample
]
