Class {
	#name : 'ApplicationMethodStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#instVars : [
		'applicationPackages'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'initialization' }
ApplicationMethodStrategy class >> setUpForApplicationPackages: aListOfPackages [

    ^ self new
          setUpForApplicationPackages: aListOfPackages;
          yourself
]

{ #category : 'api' }
ApplicationMethodStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ (self isApplicationMethod: anAllocationGraphNode)
      & (self hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode)
      & (self edgesHaveSameAllocatedObjectTypes: aListOfEdges)
]

{ #category : 'private' }
ApplicationMethodStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package
]

{ #category : 'private' }
ApplicationMethodStrategy >> setUpForApplicationPackages: aListOfPackages [

    applicationPackages := aListOfPackages
]
