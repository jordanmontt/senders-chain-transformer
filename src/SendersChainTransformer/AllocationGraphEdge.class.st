Class {
	#name : 'AllocationGraphEdge',
	#superclass : 'Object',
	#instVars : [
		'offset',
		'allocNodeStatistics',
		'targetNode',
		'sourceNode'
	],
	#category : 'SendersChainTransformer',
	#package : 'SendersChainTransformer'
}

{ #category : 'accessing' }
AllocationGraphEdge class >> targetNode: node sourceNode: aSourceNode offset: anInteger [

	^ self new
		  targetNode: node;
		  sourceNode: aSourceNode;
		  offset: anInteger;
		  yourself
]

{ #category : 'accessing' }
AllocationGraphEdge >> sourceNode: anAllocationGraphNode [

	sourceNode := anAllocationGraphNode
]
