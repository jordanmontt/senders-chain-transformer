Class {
	#name : 'AllocationSiteIdentificationStrategy',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfEdges [
	"It is expected that the allocation paht is set by this method."

	^ self subclassResponsibility
]

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> setupForGraph: allocationGraph andSamples: samples [

	"Override me"
]
