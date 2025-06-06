Class {
	#name : 'AllocationGraphStructure',
	#superclass : 'Object',
	#instVars : [
		'isAllocationSite',
		'isLeaf',
		'isTextualAllocationSite',
		'isLongLived'
	],
	#category : 'SendersChainTransformer-Allocation-Graph',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Graph'
}

{ #category : 'api' }
AllocationGraphStructure >> beAllocationSite [

	isAllocationSite := true
]

{ #category : 'api' }
AllocationGraphStructure >> beLeaf [

	isLeaf := true
]

{ #category : 'api' }
AllocationGraphStructure >> beLongLived [

	isLongLived := true
]

{ #category : 'api' }
AllocationGraphStructure >> beTextualAllocationSite [

	isTextualAllocationSite := true
]

{ #category : 'initialization' }
AllocationGraphStructure >> initialize [

	super initialize.
	isAllocationSite := false.
	isTextualAllocationSite := false.
	isLongLived := false
]

{ #category : 'testing' }
AllocationGraphStructure >> isAllocationSite [

	^ isAllocationSite
]

{ #category : 'accessing' }
AllocationGraphStructure >> isLongLived [ 

	^ isLongLived
]

{ #category : 'testing' }
AllocationGraphStructure >> isTextualAllocationSite [

	^ isTextualAllocationSite
]
