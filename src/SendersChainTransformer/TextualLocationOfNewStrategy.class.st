Class {
	#name : 'TextualLocationOfNewStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'as yet unclassified' }
TextualLocationOfNewStrategy >> identifyAllocationSites: objectAllocations [
	"do nothing as ephemerons have already the textual location as the allocation site"
]

{ #category : 'as yet unclassified' }
TextualLocationOfNewStrategy >> stopCriterionForAllocatedClass: allocatedObjectClass receiverPackage: receiverClass [

	^ (allocatedObjectClass = receiverClass or: [ allocatedObjectClass inheritsFrom: receiverClass ]) not
]
