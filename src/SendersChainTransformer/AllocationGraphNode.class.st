Class {
	#name : 'AllocationGraphNode',
	#superclass : 'Object',
	#instVars : [
		'method',
		'edges',
		'isAllocationSite',
		'isLeaf',
		'callers',
		'isTextualAllocationSite'
	],
	#category : 'SendersChainTransformer-Allocation-Graph',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Graph'
}

{ #category : 'api' }
AllocationGraphNode >> addCallTo: anAllocationGraphNode withOffset: anOffset [

	^ (edges 
			at: (MethodWithOffset method: anAllocationGraphNode method offset: anOffset)
			ifAbsentPut: [
				AllocationGraphEdge targetNode: anAllocationGraphNode sourceNode: self offset: anOffset ])
		increaseNumberOfCalls;
		yourself
]

{ #category : 'api' }
AllocationGraphNode >> addCaller: anAllocationGraphNode [

	callers add: anAllocationGraphNode
]

{ #category : 'accessing' }
AllocationGraphNode >> allocatedSamples [

	^ edges values flatCollect: #allocatedSamples
]

{ #category : 'api' }
AllocationGraphNode >> beAllocationSite [

	isAllocationSite := true
]

{ #category : 'api' }
AllocationGraphNode >> beLeaf [

	isLeaf := true
]

{ #category : 'api' }
AllocationGraphNode >> beTextualAllocationSite [

	isTextualAllocationSite := true
]

{ #category : 'accessing' }
AllocationGraphNode >> callers [
	^ callers
]

{ #category : 'accessing' }
AllocationGraphNode >> edges [

	^ edges values
]

{ #category : 'accessing' }
AllocationGraphNode >> edges: anObject [

	edges := anObject
]

{ #category : 'initialization' }
AllocationGraphNode >> initialize [

	super initialize.
	edges := Dictionary new.
	callers := Set new.
	isAllocationSite := false.
	isTextualAllocationSite := false.
	isLeaf := false
]

{ #category : 'inspector' }
AllocationGraphNode >> inspector [

	<inspectorPresentationOrder: 0 title: 'Code'>
	^ method inspectionSource
]

{ #category : 'testing' }
AllocationGraphNode >> isAllocationSite [

	^ isAllocationSite
]

{ #category : 'testing' }
AllocationGraphNode >> isLeaf [

	^ isLeaf
]

{ #category : 'testing' }
AllocationGraphNode >> isTextualAllocationSite [

	^ isTextualAllocationSite
]

{ #category : 'accessing' }
AllocationGraphNode >> method [

	^ method
]

{ #category : 'accessing' }
AllocationGraphNode >> method: aCollection [ 
	method := aCollection
]

{ #category : 'accessing' }
AllocationGraphNode >> numberOfCalls [

	isLeaf ifTrue: [
		^ callers sum: [ :caller | (caller edges detect: [ :edge | edge targetNode = self ]) numberOfCalls ] ].

	^ edges sum: #numberOfCalls
]

{ #category : 'printing' }
AllocationGraphNode >> printOn: aStream [

	aStream
		print: method methodClass;
		nextPutAll: '>>';
		print: method selector
]
