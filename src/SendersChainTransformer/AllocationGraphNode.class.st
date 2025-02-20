Class {
	#name : 'AllocationGraphNode',
	#superclass : 'Object',
	#instVars : [
		'method',
		'edges',
		'isAllocationSite',
		'isLeaf'
	],
	#category : 'SendersChainTransformer',
	#package : 'SendersChainTransformer'
}

{ #category : 'adding' }
AllocationGraphNode >> addCallTo: anAllocationGraphNode withOffset: anOffset [

	^ (edges
		   at: (MethodWithOffset
					method: anAllocationGraphNode method
					offset: anOffset)
		   ifAbsentPut: [ AllocationGraphEdge
					targetNode: anAllocationGraphNode
					sourceNode: self
					offset: anOffset ]) yourself
]

{ #category : 'initialization' }
AllocationGraphNode >> beLeaf [

	isLeaf := true
]

{ #category : 'initialization' }
AllocationGraphNode >> initialize [

	super initialize.
	edges := Dictionary new.
	isAllocationSite := false.
	isLeaf := false
]

{ #category : 'accessing' }
AllocationGraphNode >> inspector [

	<inspectorPresentationOrder: 0 title: 'Code'>
	^ method inspectionSource
]

{ #category : 'accessing' }
AllocationGraphNode >> isLeaf [
	^ isLeaf
]
