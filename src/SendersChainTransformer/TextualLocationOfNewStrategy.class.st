Class {
	#name : 'TextualLocationOfNewStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
TextualLocationOfNewStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [
    "It is expected that the allocation paht is set by this method."

    "anAllocationGraphNode isTextualAllocationSite ""The profiler gives by default the textual allocation site""
			ifTrue: [ anAllocationGraphNode appendPath: aListOfNodes ]."

    ^ anAllocationGraphNode isTextualAllocationSite and: [
          aListOfEdges allSatisfy: [ :edge | edge isLongLived ] ]
]
