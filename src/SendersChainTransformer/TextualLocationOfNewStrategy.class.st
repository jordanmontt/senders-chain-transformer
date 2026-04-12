Class {
	#name : 'TextualLocationOfNewStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'initialization' }
TextualLocationOfNewStrategy class >> setUpForGraph: allocationGarph [

    ^ self new
          setUpForGraph: allocationGarph;
          yourself
]

{ #category : 'api' }
TextualLocationOfNewStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ anAllocationGraphNode isTextualAllocationSite
]

{ #category : 'api' }
TextualLocationOfNewStrategy >> setUpForGraph: allocationGraph [

    | textualAllocationMethods samples |
    samples := allocationGraph samples.
    textualAllocationMethods := samples collect: #textualAllocatorMethod as: Set.
    textualAllocationMethods do: [ :aMethod | (allocationGraph nodeFor: aMethod) beTextualAllocationSite ]
]
