Class {
	#name : 'PathSensitivePretenuringStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
PathSensitivePretenuringStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: pathUntilNow [

	pathUntilNow ifEmpty: [ ^ false ].
	^ pathUntilNow last isLongLived
]
