Class {
	#name : 'AllocationGraphEdge',
	#superclass : 'Object',
	#instVars : [
		'offset',
		'allocNodeStatistics',
		'targetNode',
		'sourceNode'
	],
	#category : 'SendersChainTransformer-Allocation-Graph',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Graph'
}

{ #category : 'accessing' }
AllocationGraphEdge class >> targetNode: node sourceNode: aSourceNode offset: anInteger [

	^ self new
		  targetNode: node;
		  sourceNode: aSourceNode;
		  offset: anInteger;
		  yourself
]

{ #category : 'as yet unclassified' }
AllocationGraphEdge >> allocatedSamples [

	^ allocNodeStatistics allocatedSamples
]

{ #category : 'initialization' }
AllocationGraphEdge >> initialize [

	super initialize.
	allocNodeStatistics := AllocationGraphStats new
]

{ #category : 'accessing' }
AllocationGraphEdge >> key [

    ^ sourceNode
]

{ #category : 'accessing' }
AllocationGraphEdge >> offset [
	^ offset
]

{ #category : 'accessing' }
AllocationGraphEdge >> offset: anInteger [

	offset := anInteger
]

{ #category : 'printing' }
AllocationGraphEdge >> printOn: aStream [

	aStream
		nextPutAll: sourceNode method selector;
		nextPutAll: ' -> ';
		nextPutAll: targetNode method selector;
		nextPutAll: ' weight ';
		print: self allocatedSamples size
]

{ #category : 'accessing' }
AllocationGraphEdge >> sourceNode [

	^ sourceNode
]

{ #category : 'accessing' }
AllocationGraphEdge >> sourceNode: anAllocationGraphNode [

	sourceNode := anAllocationGraphNode
]

{ #category : 'accessing' }
AllocationGraphEdge >> targetNode [

	^ targetNode
]

{ #category : 'accessing' }
AllocationGraphEdge >> targetNode: anObject [

	targetNode := anObject
]

{ #category : 'as yet unclassified' }
AllocationGraphEdge >> updateFromSample: aSample [

"| stats |
stats := allocNodeStatistics at: aSample allocatedObjectClass ifAbsentPut: AllocationGraphStats new"
	allocNodeStatistics updateFromSample: aSample
]
