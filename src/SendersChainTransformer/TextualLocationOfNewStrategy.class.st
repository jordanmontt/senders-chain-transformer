Class {
	#name : 'TextualLocationOfNewStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
TextualLocationOfNewStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfNodes [

	"The profiler gives by default the textual allocation site"
	^ anAllocationGraphNode isTextualAllocationSite
]
