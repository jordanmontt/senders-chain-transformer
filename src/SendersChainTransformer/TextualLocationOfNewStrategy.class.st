Class {
	#name : 'TextualLocationOfNewStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
TextualLocationOfNewStrategy >> identifyAllocationSites: objectAllocations [
	"do nothing as ephemerons have already the textual location as the allocation site"
]

{ #category : 'api' }
TextualLocationOfNewStrategy >> isAllocationSite: anAllocationGraphNode [

	^ anAllocationGraphNode isTextualAllocationSite
]

{ #category : 'internal' }
TextualLocationOfNewStrategy >> stopCriterionForAllocatedClass: allocatedObjectClass receiverPackage: receiverClass [

	^ (allocatedObjectClass = receiverClass or: [ allocatedObjectClass inheritsFrom: receiverClass ]) not
]
