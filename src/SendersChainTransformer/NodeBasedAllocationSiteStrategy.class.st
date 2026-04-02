Class {
	#name : 'NodeBasedAllocationSiteStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
NodeBasedAllocationSiteStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfEdges [

    ^ anAllocatorNode isAllocationSite
]
