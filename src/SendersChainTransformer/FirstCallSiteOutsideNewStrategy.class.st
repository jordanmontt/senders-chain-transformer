Class {
	#name : 'FirstCallSiteOutsideNewStrategy',
	#superclass : 'TextualLocationOfNewStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
FirstCallSiteOutsideNewStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ anAllocationGraphNode isTextualAllocationSite not
      & (self hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode)
      & (self edgesHaveSameAllocatedObjectTypes: aListOfEdges)
]
