Class {
	#name : 'FirstCallSiteStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'initialization' }
FirstCallSiteStrategy class >> setUpForApplicationPackages: aListOfPackages [

    ^ self new
]

{ #category : 'api' }
FirstCallSiteStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ (self hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode)
      & (self edgesHaveSameAllocatedObjectTypes: aListOfEdges)
]
