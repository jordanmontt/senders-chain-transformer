Class {
	#name : 'CallerOfNewStrategy',
	#superclass : 'TextualLocationOfNewStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
CallerOfNewStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ anAllocationGraphNode isLeaf not
      and: [ (aListOfEdges size > 1) "if it has one edge it means that the node is the caller of basicNew"
      and: [ (self hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode)
      and: [ (self edgesHaveSameAllocatedObjectTypes: aListOfEdges) ] ] ]
]
