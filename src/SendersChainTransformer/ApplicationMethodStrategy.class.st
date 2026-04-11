Class {
	#name : 'ApplicationMethodStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#instVars : [
		'applicationPackages'
	],
	#classVars : [
		'KernelPackages'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'instance creation' }
ApplicationMethodStrategy class >> applicationPackages: aCol [

    ^ self new
          applicationPackages: aCol;
          yourself
]

{ #category : 'class initialization' }
ApplicationMethodStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #packageName
]

{ #category : 'accessing' }
ApplicationMethodStrategy >> applicationPackages: aCollectionOfPackages [

    applicationPackages := aCollectionOfPackages
]

{ #category : 'api' }
ApplicationMethodStrategy >> edgesHaveSameAllocatedObjectTypes: aListOfEdges [

    | typesInAllocatorEdge |
    aListOfEdges ifEmpty: [ ^ true ].

    typesInAllocatorEdge := aListOfEdges first allocatedSamples collect: #allocatedObjectClass as: Set.
    ^ aListOfEdges allButFirst allSatisfy: [ :edge |
        (edge allocatedSamples collect: #allocatedObjectClass as: Set) includesAll: typesInAllocatorEdge ]
]

{ #category : 'api' }
ApplicationMethodStrategy >> hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode [

    ^ (anAllocationGraphNode incomingEdges select: #isShortLived) isEmpty
]

{ #category : 'api' }
ApplicationMethodStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ (self isApplicationMethod: anAllocationGraphNode)
      & (self hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode)
      & (self edgesHaveSameAllocatedObjectTypes: aListOfEdges)
]

{ #category : 'api' }
ApplicationMethodStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package
]

{ #category : 'api' }
ApplicationMethodStrategy >> isKernelMethod: anAllocationGraphNode [

    ^ KernelPackages includes: anAllocationGraphNode method package name
]
